import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import '../../models/printer_config.dart';
import '../../models/receipt_document.dart';

class PrinterReceiptBuilder {
  PrinterReceiptBuilder({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  static const logoAssetPath = 'assets/branding/pos-logo.png';

  final AssetBundle _assetBundle;

  Future<List<int>> buildReceipt({
    required ReceiptDocument document,
    required PrinterConfig printerConfig,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(_paperSize(printerConfig.paperSize), profile);
    final bytes = <int>[];

    bytes.addAll(generator.reset());
    if (printerConfig.printLogo) {
      final logo = await _loadLogo();
      if (logo != null) {
        bytes.addAll(generator.image(logo, align: PosAlign.center));
      }
    }

    bytes.addAll(
      generator.text(
        document.storeName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      ),
    );
    bytes.addAll(
      generator.text(
        'THERMAL RECEIPT',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('Order: ${document.orderNo}'));
    bytes.addAll(
      generator.text(
        'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(document.createdAt.toLocal())}',
      ),
    );
    bytes.addAll(generator.text('Cashier: ${document.cashierName}'));
    bytes.addAll(generator.text('Payment: ${document.paymentMethodLabel}'));
    bytes.addAll(generator.hr());

    for (final item in document.items) {
      bytes.addAll(
        generator.text(item.label, styles: const PosStyles(bold: true)),
      );
      if ((item.sku ?? '').isNotEmpty) {
        bytes.addAll(generator.text('SKU: ${item.sku}'));
      }
      bytes.addAll(
        generator.row([
          PosColumn(text: '${item.quantity} x', width: 2),
          PosColumn(
            text: _money(item.unitPrice),
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: _money(item.subtotal),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ]),
      );
    }

    bytes.addAll(generator.hr());
    bytes.addAll(_summaryRow(generator, 'Subtotal', document.totalAmount));
    bytes.addAll(_summaryRow(generator, 'Discount', document.discountAmount));
    bytes.addAll(_summaryRow(generator, 'VAT 7%', document.vatAmount));
    bytes.addAll(_summaryRow(generator, 'NET', document.netAmount, bold: true));
    bytes.addAll(_summaryRow(generator, 'Received', document.amountReceived));
    bytes.addAll(_summaryRow(generator, 'Change', document.changeAmount));
    bytes.addAll(generator.hr());
    bytes.addAll(
      generator.qrcode(
        document.qrPayload,
        size: QRSize.size6,
        cor: QRCorrection.L,
      ),
    );
    bytes.addAll(
      generator.text(
        'Thank you for your purchase',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ),
    );
    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut());
    return bytes;
  }

  List<int> _summaryRow(
    Generator generator,
    String label,
    double amount, {
    bool bold = false,
  }) {
    return generator.row([
      PosColumn(
        text: label,
        width: 6,
        styles: PosStyles(bold: bold),
      ),
      PosColumn(
        text: _money(amount),
        width: 6,
        styles: PosStyles(align: PosAlign.right, bold: bold),
      ),
    ]);
  }

  PaperSize _paperSize(ReceiptPaperSize paperSize) {
    return switch (paperSize) {
      ReceiptPaperSize.mm58 => PaperSize.mm58,
      ReceiptPaperSize.mm80 => PaperSize.mm80,
    };
  }

  Future<img.Image?> _loadLogo() async {
    try {
      final data = await _assetBundle.load(logoAssetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      return img.decodeImage(bytes);
    } catch (_) {
      return null;
    }
  }

  String _money(double amount) => 'THB ${amount.toStringAsFixed(2)}';
}
