import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/qr_code_scanner_view.dart';

import 'confirm_view.dart';

class Const {
  static const routeFirstPage = '/home';
  static const routeQRCodeScanner = '/qr-code-scanner';
  static const routeConfirm = '/confirm';
}

class FirstPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      routes: <String, WidgetBuilder>{
        Const.routeFirstPage: (BuildContext context) => FirstPageView(),
        Const.routeQRCodeScanner: (BuildContext context) => QRCodeScannerView(),
        Const.routeConfirm: (BuildContext context) => ConfirmView(),
      },
      home: _FirstPage(),
    );
  }
}

class _FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('QR code scanner'),
      ),
      body: _buildPage(context),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, Const.routeQRCodeScanner),
        child: const Text('Launch QR code scanner'),
      ),
    );
  }
}
