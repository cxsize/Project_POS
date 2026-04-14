import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/service_providers.dart';
import '../models/printer_config.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bluetoothAddressController;
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  PrinterConnectionType _connectionType = PrinterConnectionType.bluetooth;
  ReceiptPaperSize _paperSize = ReceiptPaperSize.mm80;
  bool _isEnabled = false;
  bool _autoPrint = false;
  bool _printLogo = true;
  bool _isLoading = true;
  bool _loadingBluetoothDevices = false;
  List<BluetoothPrinterDevice> _bluetoothDevices = const [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bluetoothAddressController = TextEditingController();
    _hostController = TextEditingController();
    _portController = TextEditingController(text: '9100');
    _loadPrinterConfig();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bluetoothAddressController.dispose();
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _loadPrinterConfig() async {
    final config = await ref.read(printerServiceProvider).loadConfig();
    if (!mounted) {
      return;
    }

    setState(() {
      _connectionType = config.connectionType;
      _paperSize = config.paperSize;
      _isEnabled = config.isEnabled;
      _autoPrint = config.autoPrint;
      _printLogo = config.printLogo;
      _nameController.text = config.displayName ?? '';
      _bluetoothAddressController.text = config.bluetoothAddress ?? '';
      _hostController.text = config.host ?? '';
      _portController.text = (config.port ?? 9100).toString();
      _isLoading = false;
    });
  }

  Future<void> _loadBluetoothDevices() async {
    setState(() {
      _loadingBluetoothDevices = true;
    });

    try {
      final devices = await ref
          .read(printerServiceProvider)
          .getPairedBluetoothPrinters();
      if (!mounted) {
        return;
      }
      setState(() {
        _bluetoothDevices = devices;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to read paired printers: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingBluetoothDevices = false;
        });
      }
    }
  }

  Future<void> _savePrinterConfig() async {
    final port = int.tryParse(_portController.text.trim());
    final config = PrinterConfig(
      connectionType: _connectionType,
      paperSize: _paperSize,
      displayName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      bluetoothAddress: _bluetoothAddressController.text.trim().isEmpty
          ? null
          : _bluetoothAddressController.text.trim(),
      host: _hostController.text.trim().isEmpty
          ? null
          : _hostController.text.trim(),
      port: port,
      isEnabled: _isEnabled,
      autoPrint: _autoPrint,
      printLogo: _printLogo,
    );

    final validationError = _validate(config);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    await ref.read(printerServiceProvider).saveConfig(config);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Printer settings saved.')));
  }

  String? _validate(PrinterConfig config) {
    if (!config.isEnabled) {
      return null;
    }

    if (config.isBluetooth && (config.bluetoothAddress ?? '').trim().isEmpty) {
      return 'Select or enter a Bluetooth printer address.';
    }

    if (config.isLan && (config.host ?? '').trim().isEmpty) {
      return 'Enter the LAN printer host or IP.';
    }

    if (config.isLan && (config.port ?? 0) <= 0) {
      return 'Enter a valid LAN printer port.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(auth.user?.username ?? 'Unknown'),
            subtitle: Text('Role: ${auth.user?.role ?? "N/A"}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: const Text('POS v0.1.0'),
          ),
          const Divider(),
          Text(
            'Thermal Printer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isEnabled,
            onChanged: (value) => setState(() => _isEnabled = value),
            title: const Text('Enable receipt printing'),
            subtitle: const Text(
              'Use this device to print 58mm or 80mm receipts.',
            ),
          ),
          SwitchListTile(
            value: _autoPrint,
            onChanged: _isEnabled
                ? (value) => setState(() => _autoPrint = value)
                : null,
            title: const Text('Auto-print after payment'),
          ),
          SwitchListTile(
            value: _printLogo,
            onChanged: _isEnabled
                ? (value) => setState(() => _printLogo = value)
                : null,
            title: const Text('Print logo on receipt'),
          ),
          const SizedBox(height: 8),
          SegmentedButton<PrinterConnectionType>(
            segments: const [
              ButtonSegment(
                value: PrinterConnectionType.bluetooth,
                icon: Icon(Icons.bluetooth),
                label: Text('Bluetooth'),
              ),
              ButtonSegment(
                value: PrinterConnectionType.lan,
                icon: Icon(Icons.lan),
                label: Text('LAN'),
              ),
            ],
            selected: {_connectionType},
            onSelectionChanged: (selection) {
              setState(() {
                _connectionType = selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
          SegmentedButton<ReceiptPaperSize>(
            segments: const [
              ButtonSegment(value: ReceiptPaperSize.mm58, label: Text('58mm')),
              ButtonSegment(value: ReceiptPaperSize.mm80, label: Text('80mm')),
            ],
            selected: {_paperSize},
            onSelectionChanged: (selection) {
              setState(() {
                _paperSize = selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Printer name',
              hintText: 'Counter Printer',
            ),
          ),
          const SizedBox(height: 12),
          if (_connectionType == PrinterConnectionType.bluetooth) ...[
            TextField(
              controller: _bluetoothAddressController,
              decoration: const InputDecoration(
                labelText: 'Bluetooth MAC address',
                hintText: '66:02:BD:06:18:7B',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadingBluetoothDevices
                  ? null
                  : _loadBluetoothDevices,
              icon: _loadingBluetoothDevices
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.devices),
              label: const Text('Load paired printers'),
            ),
            if (_bluetoothDevices.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._bluetoothDevices.map(
                (device) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.print),
                  title: Text(
                    device.name.isEmpty ? device.address : device.name,
                  ),
                  subtitle: Text(device.address),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() {
                        _nameController.text = device.name;
                        _bluetoothAddressController.text = device.address;
                      });
                    },
                    child: const Text('Use'),
                  ),
                ),
              ),
            ],
          ] else ...[
            TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'LAN printer host / IP',
                hintText: '192.168.1.120',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'TCP port',
                hintText: '9100',
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _savePrinterConfig,
            icon: const Icon(Icons.save),
            label: const Text('Save printer settings'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
