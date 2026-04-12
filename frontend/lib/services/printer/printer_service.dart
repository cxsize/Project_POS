import 'dart:io';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../../models/printer_config.dart';
import '../../models/receipt_document.dart';
import '../../models/user.dart';
import 'printer_receipt_builder.dart';
import 'printer_settings_store.dart';

class PrinterService {
  PrinterService({
    PrinterSettingsStore? settingsStore,
    PrinterReceiptBuilder? receiptBuilder,
    Map<PrinterConnectionType, PrinterTransport>? transports,
  }) : _settingsStore = settingsStore ?? SecurePrinterSettingsStore(),
       _receiptBuilder = receiptBuilder ?? PrinterReceiptBuilder(),
       _transports =
           transports ??
           {
             PrinterConnectionType.bluetooth: BluetoothPrinterTransport(),
             PrinterConnectionType.lan: LanPrinterTransport(),
           };

  final PrinterSettingsStore _settingsStore;
  final PrinterReceiptBuilder _receiptBuilder;
  final Map<PrinterConnectionType, PrinterTransport> _transports;

  Future<PrinterConfig> loadConfig() async {
    return await _settingsStore.read() ?? PrinterConfig.empty;
  }

  Future<void> saveConfig(PrinterConfig config) {
    return _settingsStore.write(config);
  }

  Future<void> clearConfig() {
    return _settingsStore.clear();
  }

  Future<List<BluetoothPrinterDevice>> getPairedBluetoothPrinters() async {
    final devices = await PrintBluetoothThermal.pairedBluetooths;
    return devices
        .map(
          (device) => BluetoothPrinterDevice(
            name: device.name,
            address: device.macAdress,
          ),
        )
        .where((device) => device.address.trim().isNotEmpty)
        .toList()
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  Future<bool> hasBluetoothPermission() async {
    try {
      return await PrintBluetoothThermal.isPermissionBluetoothGranted;
    } catch (_) {
      return true;
    }
  }

  Future<void> printSaleReceipt({
    required Order order,
    required List<CartItem> cartItems,
    required User user,
    double changeAmount = 0,
  }) async {
    final printerConfig = await loadConfig();
    if (!printerConfig.isConfigured) {
      throw const PrinterException('Thermal printer is not configured yet.');
    }

    final document = ReceiptDocument.fromSale(
      order: order,
      cartItems: cartItems,
      cashierName: user.fullName.trim().isNotEmpty
          ? user.fullName
          : user.username,
      changeAmount: changeAmount,
    );
    final bytes = await _receiptBuilder.buildReceipt(
      document: document,
      printerConfig: printerConfig,
    );
    final transport = _transports[printerConfig.connectionType];
    if (transport == null) {
      throw PrinterException(
        'Unsupported printer transport: ${printerConfig.connectionType.name}',
      );
    }

    await transport.print(bytes, printerConfig);
  }
}

abstract class PrinterTransport {
  Future<void> print(List<int> bytes, PrinterConfig config);
}

class BluetoothPrinterTransport implements PrinterTransport {
  @override
  Future<void> print(List<int> bytes, PrinterConfig config) async {
    final address = config.bluetoothAddress?.trim() ?? '';
    if (address.isEmpty) {
      throw const PrinterException('Bluetooth printer address is missing.');
    }

    final hasPermission = await _hasPermission();
    if (!hasPermission) {
      throw const PrinterException(
        'Bluetooth permission is required to access paired printers.',
      );
    }

    final connected = await PrintBluetoothThermal.connectionStatus;
    if (!connected) {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: address,
      );
      if (!result) {
        throw PrinterException(
          'Unable to connect to Bluetooth printer ${config.displayName ?? address}.',
        );
      }
    }

    final printed = await PrintBluetoothThermal.writeBytes(bytes);
    if (!printed) {
      throw PrinterException(
        'Bluetooth printer ${config.displayName ?? address} rejected the receipt.',
      );
    }
  }

  Future<bool> _hasPermission() async {
    try {
      return await PrintBluetoothThermal.isPermissionBluetoothGranted;
    } catch (_) {
      return true;
    }
  }
}

class LanPrinterTransport implements PrinterTransport {
  @override
  Future<void> print(List<int> bytes, PrinterConfig config) async {
    final host = config.host?.trim() ?? '';
    final port = config.port ?? 0;
    if (host.isEmpty || port <= 0) {
      throw const PrinterException('LAN printer host or port is invalid.');
    }

    Socket? socket;
    try {
      socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.add(bytes);
      await socket.flush();
    } on SocketException catch (error) {
      throw PrinterException(
        'Unable to reach LAN printer ${config.displayName ?? host}: ${error.message}',
      );
    } finally {
      await socket?.close();
    }
  }
}

class PrinterException implements Exception {
  const PrinterException(this.message);

  final String message;

  @override
  String toString() => message;
}
