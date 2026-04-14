import 'dart:convert';
import 'dart:io';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ReceiptLineItem {
  ReceiptLineItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  final String name;
  final int qty;
  final double unitPrice;
  final double subtotal;
}

class ReceiptPrintJob {
  ReceiptPrintJob({
    required this.orderNo,
    required this.createdAt,
    required this.staffLabel,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.vat,
    required this.netTotal,
    required this.amountReceived,
    required this.change,
  });

  final String orderNo;
  final DateTime createdAt;
  final String staffLabel;
  final String paymentMethod;
  final List<ReceiptLineItem> items;
  final double subtotal;
  final double discount;
  final double vat;
  final double netTotal;
  final double amountReceived;
  final double change;
}

sealed class PrinterTarget {
  const PrinterTarget();
}

class NetworkPrinterTarget extends PrinterTarget {
  const NetworkPrinterTarget({required this.host, this.port = 9100});

  final String host;
  final int port;
}

class BluetoothPrinterTarget extends PrinterTarget {
  const BluetoothPrinterTarget({required this.deviceAddress});

  final String deviceAddress;
}

abstract class BluetoothPrinterClient {
  Future<bool> ensurePermissionGranted();
  Future<bool> ensureBluetoothEnabled();
  Future<bool> connect(String deviceAddress);
  Future<bool> writeBytes(List<int> bytes);
  Future<bool> disconnect();
}

class PluginBluetoothPrinterClient implements BluetoothPrinterClient {
  @override
  Future<bool> ensurePermissionGranted() {
    return PrintBluetoothThermal.isPermissionBluetoothGranted;
  }

  @override
  Future<bool> ensureBluetoothEnabled() {
    return PrintBluetoothThermal.bluetoothEnabled;
  }

  @override
  Future<bool> connect(String deviceAddress) {
    return PrintBluetoothThermal.connect(macPrinterAddress: deviceAddress);
  }

  @override
  Future<bool> writeBytes(List<int> bytes) {
    return PrintBluetoothThermal.writeBytes(bytes);
  }

  @override
  Future<bool> disconnect() {
    return PrintBluetoothThermal.disconnect;
  }
}

class ThermalPrinterService {
  ThermalPrinterService({BluetoothPrinterClient? bluetoothPrinterClient})
    : _bluetoothPrinterClient =
          bluetoothPrinterClient ?? PluginBluetoothPrinterClient();

  final BluetoothPrinterClient _bluetoothPrinterClient;

  Future<void> printReceipt({
    required ReceiptPrintJob job,
    required PrinterTarget target,
  }) async {
    final bytes = EscPosReceiptBuilder().build(job);

    if (target is NetworkPrinterTarget) {
      await _printViaTcp(target, bytes);
      return;
    }

    if (target is BluetoothPrinterTarget) {
      await _printViaBluetooth(target, bytes);
      return;
    }

    throw UnsupportedError('Unknown printer target type: $target');
  }

  Future<void> _printViaTcp(
    NetworkPrinterTarget target,
    List<int> bytes,
  ) async {
    final socket = await Socket.connect(
      target.host,
      target.port,
      timeout: const Duration(seconds: 5),
    );

    try {
      socket.add(bytes);
      await socket.flush();
      await Future<void>.delayed(const Duration(milliseconds: 150));
    } finally {
      await socket.close();
    }
  }

  Future<void> _printViaBluetooth(
    BluetoothPrinterTarget target,
    List<int> bytes,
  ) async {
    final hasPermission = await _bluetoothPrinterClient
        .ensurePermissionGranted();
    if (!hasPermission) {
      throw StateError('Bluetooth permission is required to print receipt.');
    }

    final bluetoothEnabled = await _bluetoothPrinterClient
        .ensureBluetoothEnabled();
    if (!bluetoothEnabled) {
      throw StateError('Bluetooth is disabled on this device.');
    }

    final isConnected = await _bluetoothPrinterClient.connect(
      target.deviceAddress,
    );
    if (!isConnected) {
      throw StateError(
        'Unable to connect to bluetooth printer ${target.deviceAddress}.',
      );
    }

    try {
      final didWrite = await _bluetoothPrinterClient.writeBytes(bytes);
      if (!didWrite) {
        throw StateError('Failed to write receipt bytes to printer.');
      }
    } finally {
      await _bluetoothPrinterClient.disconnect();
    }
  }
}

class EscPosReceiptBuilder {
  List<int> build(ReceiptPrintJob job) {
    final bytes = <int>[];

    void writeText(String text) {
      bytes.addAll(
        const LineSplitter().convert(text).expand((line) {
          return [...utf8.encode(line), 0x0A];
        }),
      );
    }

    bytes.addAll(const [0x1B, 0x40]);
    bytes.addAll(const [0x1B, 0x61, 0x01]);
    bytes.addAll(const [0x1D, 0x21, 0x11]);
    writeText('PROJECT POS');
    bytes.addAll(const [0x1D, 0x21, 0x00]);
    writeText('Sales Receipt');
    writeText('------------------------------');

    bytes.addAll(const [0x1B, 0x61, 0x00]);
    writeText('Order : ${job.orderNo}');
    writeText('Date  : ${_formatDate(job.createdAt)}');
    writeText('Staff : ${job.staffLabel}');
    writeText('Pay   : ${job.paymentMethod.toUpperCase()}');
    writeText('------------------------------');

    for (final item in job.items) {
      writeText(_fit(item.name, 30));
      writeText(
        '${item.qty} x ${_money(item.unitPrice)}'.padRight(20) +
            _money(item.subtotal).padLeft(10),
      );
    }

    writeText('------------------------------');
    writeText('Subtotal'.padRight(20) + _money(job.subtotal).padLeft(10));
    writeText('Discount'.padRight(20) + _money(job.discount).padLeft(10));
    writeText('VAT'.padRight(20) + _money(job.vat).padLeft(10));
    writeText('Net Total'.padRight(20) + _money(job.netTotal).padLeft(10));
    writeText('Received'.padRight(20) + _money(job.amountReceived).padLeft(10));
    writeText('Change'.padRight(20) + _money(job.change).padLeft(10));

    writeText('------------------------------');
    bytes.addAll(const [0x1B, 0x61, 0x01]);
    writeText('PromptPay QR');
    _appendQrCode(bytes, _buildPromptPayPayload(job.orderNo, job.netTotal));
    writeText('Scan to record payment details');
    writeText('Thank you and see you again!');

    bytes.addAll(const [0x0A, 0x0A, 0x0A]);
    bytes.addAll(const [0x1D, 0x56, 0x00]);
    return bytes;
  }

  void _appendQrCode(List<int> output, String payload) {
    final data = utf8.encode(payload);

    output.addAll(const [0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00]);
    output.addAll(const [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x06]);
    output.addAll(const [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x45, 0x30]);

    final size = data.length + 3;
    final pL = size & 0xFF;
    final pH = (size >> 8) & 0xFF;
    output.addAll([0x1D, 0x28, 0x6B, pL, pH, 0x31, 0x50, 0x30]);
    output.addAll(data);

    output.addAll(const [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30]);
    output.add(0x0A);
  }

  String _buildPromptPayPayload(String orderNo, double amount) {
    return 'PROMPTPAY|ORDER:$orderNo|AMOUNT:${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${twoDigits(value.month)}-${twoDigits(value.day)} '
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
  }

  String _fit(String value, int width) {
    final normalized = value.trim();
    if (normalized.length <= width) {
      return normalized;
    }
    return '${normalized.substring(0, width - 3)}...';
  }

  String _money(double value) => value.toStringAsFixed(2);
}
