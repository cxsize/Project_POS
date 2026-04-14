import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/printer_config.dart';

abstract class PrinterSettingsStore {
  Future<PrinterConfig?> read();
  Future<void> write(PrinterConfig config);
  Future<void> clear();
}

class SecurePrinterSettingsStore implements PrinterSettingsStore {
  SecurePrinterSettingsStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _printerConfigKey = 'pos.printer.config';

  final FlutterSecureStorage _storage;

  @override
  Future<PrinterConfig?> read() async {
    final raw = await _storage.read(key: _printerConfigKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return PrinterConfig.fromJson(decoded);
  }

  @override
  Future<void> write(PrinterConfig config) async {
    await _storage.write(
      key: _printerConfigKey,
      value: jsonEncode(config.toJson()),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _printerConfigKey);
  }
}
