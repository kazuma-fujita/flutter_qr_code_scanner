import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'first_page_view.dart';

@immutable
class ConfirmViewArguments {
  const ConfirmViewArguments({required this.type, required this.data});
  final String type;
  final String data;
}

class QRCodeScannerView extends StatefulWidget {
  @override
  _QRCodeScannerViewState createState() => _QRCodeScannerViewState();
}

class _QRCodeScannerViewState extends State<QRCodeScannerView> {
  QRViewController? _qrController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isQRScanned = false;

  // ホットリロードを機能させるには、プラットフォームがAndroidの場合はカメラを一時停止するか、
  // プラットフォームがiOSの場合はカメラを再開する必要がある
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrController?.pauseCamera();
    }
    _qrController?.resumeCamera();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _checkPermissionState();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan the QR code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            // child: _buildPermissionState(context),
            child: _buildQRView(context),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _qrController?.getFlashStatus(),
                            builder: (context, snapshot) =>
                                Text('Flash: ${snapshot.data}'),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _qrController?.getCameraInfo(),
                            builder: (context, snapshot) => snapshot.data !=
                                    null
                                ? Text(
                                    'Camera facing ${describeEnum(snapshot.data!)}')
                                : const Text('loading'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.pauseCamera();
                          },
                          child: const Text(
                            'pause',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.resumeCamera();
                          },
                          child: const Text(
                            'resume',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.green,
        borderRadius: 16,
        borderLength: 24,
        borderWidth: 8,
        // cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController qrController) {
    setState(() {
      _qrController = qrController;
    });
    // QRを読み込みをlistenする
    qrController.scannedDataStream.listen((scanData) {
      // QRのデータが取得出来ない場合SnackBar表示
      if (scanData.code == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code data does not exist'),
          ),
        );
      }
      // 次の画面へ遷移
      _transitionToNextScreen(describeEnum(scanData.format), scanData.code!);
    });
  }

  Future<void> _transitionToNextScreen(String type, String data) async {
    if (!_isQRScanned) {
      // カメラを一時停止
      _qrController?.pauseCamera();
      _isQRScanned = true;
      // 次の画面へ遷移
      await Navigator.pushNamed(
        context,
        Const.routeConfirm,
        arguments: ConfirmViewArguments(type: type, data: data),
      ).then(
        // 遷移先画面から戻った場合カメラを再開
        (value) {
          _qrController?.resumeCamera();
          _isQRScanned = false;
        },
      );
    }
  }
  // Future<void> _checkPermissionState() async {
  //   if (!await Permission.camera.status.isGranted) {
  //     _showRequestPermissionDialog(context);
  //   }
  // }
  //
  // Future<void> _showRequestPermissionDialog(BuildContext context) async {
  //   await showDialog<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('カメラを許可してください'),
  //         content: const Text('QRコードを読み取る為にカメラを利用します'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('キャンセル'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () async {
  //               openAppSettings();
  //             },
  //             child: const Text('設定'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
