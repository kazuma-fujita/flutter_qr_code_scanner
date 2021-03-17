import 'package:flutter/material.dart';
import 'package:flutter_qr_code_scanner/qr_code_scanner_view.dart';

import 'first_page_view.dart';

class ConfirmView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To confirm the scan results'),
      ),
      body: _buildConfirmView(context),
    );
  }

  Widget _buildConfirmView(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as ConfirmViewArguments?;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Type: ${arguments!.type} Data: ${arguments.data}'),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Scan again'),
          ),
          ElevatedButton(
            // これまでのstackを削除して最初の画面に戻る
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, Const.routeFirstPage, (route) => false),
            child: const Text('Back to first page'),
          ),
        ],
      ),
    );
  }
}
