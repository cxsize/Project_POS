enum PrinterConnectionType { bluetooth, lan }

enum ReceiptPaperSize { mm58, mm80 }

class PrinterConfig {
  const PrinterConfig({
    required this.connectionType,
    required this.paperSize,
    this.displayName,
    this.bluetoothAddress,
    this.host,
    this.port,
    this.isEnabled = false,
    this.autoPrint = false,
    this.printLogo = true,
  });

  final PrinterConnectionType connectionType;
  final ReceiptPaperSize paperSize;
  final String? displayName;
  final String? bluetoothAddress;
  final String? host;
  final int? port;
  final bool isEnabled;
  final bool autoPrint;
  final bool printLogo;

  bool get isBluetooth => connectionType == PrinterConnectionType.bluetooth;
  bool get isLan => connectionType == PrinterConnectionType.lan;

  bool get isConfigured {
    if (!isEnabled) {
      return false;
    }

    if (isBluetooth) {
      return (bluetoothAddress ?? '').trim().isNotEmpty;
    }

    return (host ?? '').trim().isNotEmpty && (port ?? 0) > 0;
  }

  PrinterConfig copyWith({
    PrinterConnectionType? connectionType,
    ReceiptPaperSize? paperSize,
    String? displayName,
    bool clearDisplayName = false,
    String? bluetoothAddress,
    bool clearBluetoothAddress = false,
    String? host,
    bool clearHost = false,
    int? port,
    bool clearPort = false,
    bool? isEnabled,
    bool? autoPrint,
    bool? printLogo,
  }) {
    return PrinterConfig(
      connectionType: connectionType ?? this.connectionType,
      paperSize: paperSize ?? this.paperSize,
      displayName: clearDisplayName ? null : displayName ?? this.displayName,
      bluetoothAddress: clearBluetoothAddress
          ? null
          : bluetoothAddress ?? this.bluetoothAddress,
      host: clearHost ? null : host ?? this.host,
      port: clearPort ? null : port ?? this.port,
      isEnabled: isEnabled ?? this.isEnabled,
      autoPrint: autoPrint ?? this.autoPrint,
      printLogo: printLogo ?? this.printLogo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connectionType': connectionType.name,
      'paperSize': paperSize.name,
      if (displayName != null) 'displayName': displayName,
      if (bluetoothAddress != null) 'bluetoothAddress': bluetoothAddress,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      'isEnabled': isEnabled,
      'autoPrint': autoPrint,
      'printLogo': printLogo,
    };
  }

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    return PrinterConfig(
      connectionType: PrinterConnectionType.values.firstWhere(
        (value) => value.name == json['connectionType'],
        orElse: () => PrinterConnectionType.bluetooth,
      ),
      paperSize: ReceiptPaperSize.values.firstWhere(
        (value) => value.name == json['paperSize'],
        orElse: () => ReceiptPaperSize.mm80,
      ),
      displayName: json['displayName']?.toString(),
      bluetoothAddress: json['bluetoothAddress']?.toString(),
      host: json['host']?.toString(),
      port: switch (json['port']) {
        int value => value,
        String value => int.tryParse(value),
        _ => null,
      },
      isEnabled: json['isEnabled'] as bool? ?? false,
      autoPrint: json['autoPrint'] as bool? ?? false,
      printLogo: json['printLogo'] as bool? ?? true,
    );
  }

  static const empty = PrinterConfig(
    connectionType: PrinterConnectionType.bluetooth,
    paperSize: ReceiptPaperSize.mm80,
  );
}

class BluetoothPrinterDevice {
  const BluetoothPrinterDevice({required this.name, required this.address});

  final String name;
  final String address;
}
