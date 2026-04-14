import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/services/thermal_printer_service.dart';

class _FakeBluetoothPrinterClient implements BluetoothPrinterClient {
  bool permissionGranted = true;
  bool bluetoothEnabled = true;
  bool connectResult = true;
  bool writeResult = true;
  bool disconnectCalled = false;
  String? connectedAddress;
  List<int>? writtenBytes;

  @override
  Future<bool> connect(String deviceAddress) async {
    connectedAddress = deviceAddress;
    return connectResult;
  }

  @override
  Future<bool> disconnect() async {
    disconnectCalled = true;
    return true;
  }

  @override
  Future<bool> ensureBluetoothEnabled() async => bluetoothEnabled;

  @override
  Future<bool> ensurePermissionGranted() async => permissionGranted;

  @override
  Future<bool> writeBytes(List<int> bytes) async {
    writtenBytes = bytes;
    return writeResult;
  }
}

void main() {
  group('EscPosReceiptBuilder', () {
    test('builds receipt bytes with summary and QR payload', () {
      final builder = EscPosReceiptBuilder();
      final bytes = builder.build(
        ReceiptPrintJob(
          orderNo: 'ORD-1001',
          createdAt: DateTime(2026, 4, 13, 11, 30),
          staffLabel: 'cashier-a',
          paymentMethod: 'cash',
          items: [
            ReceiptLineItem(
              name: 'Americano',
              qty: 2,
              unitPrice: 65,
              subtotal: 130,
            ),
          ],
          subtotal: 130,
          discount: 10,
          vat: 8.4,
          netTotal: 128.4,
          amountReceived: 200,
          change: 71.6,
        ),
      );

      expect(bytes, isNotEmpty);
      expect(bytes.first, equals(0x1B));

      final printable = utf8.decode(
        bytes.where((value) => value >= 0x20 && value <= 0x7E).toList(),
        allowMalformed: true,
      );

      expect(printable, contains('PROJECT POS'));
      expect(printable, contains('Order : ORD-1001'));
      expect(printable, contains('Net Total'));
      expect(printable, contains('PROMPTPAY|ORDER:ORD-1001|AMOUNT:128.40'));
    });
  });

  group('ThermalPrinterService', () {
    test('prints via bluetooth plugin client', () async {
      final fakeClient = _FakeBluetoothPrinterClient();
      final service = ThermalPrinterService(
        bluetoothPrinterClient: fakeClient,
      );

      await service.printReceipt(
        job: ReceiptPrintJob(
          orderNo: 'ORD-1',
          createdAt: DateTime(2026, 4, 13),
          staffLabel: 'cashier',
          paymentMethod: 'cash',
          items: [
            ReceiptLineItem(
              name: 'Tea',
              qty: 1,
              unitPrice: 35,
              subtotal: 35,
            ),
          ],
          subtotal: 35,
          discount: 0,
          vat: 2.45,
          netTotal: 37.45,
          amountReceived: 40,
          change: 2.55,
        ),
        target: const BluetoothPrinterTarget(deviceAddress: 'AA:BB'),
      );

      expect(fakeClient.connectedAddress, 'AA:BB');
      expect(fakeClient.writtenBytes, isNotNull);
      expect(fakeClient.writtenBytes, isNotEmpty);
      expect(fakeClient.disconnectCalled, isTrue);
    });

    test('throws when bluetooth permission is not granted', () async {
      final fakeClient = _FakeBluetoothPrinterClient()..permissionGranted = false;
      final service = ThermalPrinterService(
        bluetoothPrinterClient: fakeClient,
      );

      await expectLater(
        () => service.printReceipt(
          job: ReceiptPrintJob(
            orderNo: 'ORD-2',
            createdAt: DateTime(2026, 4, 13),
            staffLabel: 'cashier',
            paymentMethod: 'cash',
            items: const [],
            subtotal: 0,
            discount: 0,
            vat: 0,
            netTotal: 0,
            amountReceived: 0,
            change: 0,
          ),
          target: const BluetoothPrinterTarget(deviceAddress: 'AA:BB'),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
