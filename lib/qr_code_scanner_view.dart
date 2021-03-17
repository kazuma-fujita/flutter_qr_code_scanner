import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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
// class _QRCodeScannerViewState extends State<QRCodeScannerView>
//     with WidgetsBindingObserver {
  // Barcode? result;
  PermissionStatus? _permissionStatus;
  QRViewController? qrController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // ホットリロードを機能させるには、プラットフォームがAndroidの場合はカメラを一時停止するか、
  // プラットフォームがiOSの場合はカメラを再開する必要がある
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      qrController?.pauseCamera();
    }
    qrController?.resumeCamera();
  }

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.paused) {
  //     print('paused');
  //     qrController?.pauseCamera();
  //     // _checkPermissionState();
  //   } else if (state == AppLifecycleState.resumed) {
  //     print('resumed');
  //     await _checkPermissionState();
  //     qrController?.resumeCamera();
  //   }
  // }

  // Future<void> _requestPermission() async {
  //   final status = await Permission.camera.request();
  //   setState(() {
  //     _permissionStatus = status;
  //   });
  // }

  Future<void> _checkPermissionState() async {
    // if (_permissionStatus == null) {
    //   _requestPermission();
    //   return;
    // }
    // switch (_permissionStatus!) {
    // switch (await Permission.camera.status) {
    //   case PermissionStatus.granted:
    //     print('granted');
    //     break;
    //   case PermissionStatus.denied:
    //     print('denied');
    //     break;
    //   case PermissionStatus.restricted:
    //     print('restricted');
    //     break;
    //   case PermissionStatus.permanentlyDenied:
    //     print('permanentlyDenied');
    //     break;
    //   case PermissionStatus.limited:
    //     print('limited');
    //     break;
    // }
    final status = await Permission.camera.status;
    print(status);
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // duration: const Duration(days: 365),
          duration: const Duration(seconds: 5),
          content: const Text('QRコードを読み取る為にカメラを設定してください'),
          action: SnackBarAction(
            label: '設定',
            onPressed: () async {
              openAppSettings();
            },
          ),
        ),
      );
    }
  }

  Future<void> showRequestPermissionDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('カメラを許可してください'),
          content: const Text('QRコードを読み取る為にカメラを利用します'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                openAppSettings();
              },
              child: const Text('設定'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionState(BuildContext context) {
    if (_permissionStatus != null && !_permissionStatus!.isGranted) {
      return AlertDialog(
        title: const Text('カメラを許可してください'),
        content: const Text('QRコードを読み取る為にカメラを利用します'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              openAppSettings();
            },
            child: const Text('設定'),
          ),
        ],
      );
    } else {
      return _buildQRView(context);
    }
  }

  Future<void> _check() async {
    final status = await Permission.camera.status;
    setState(() {
      _permissionStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    _check();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan the QR code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildPermissionState(context),
            // child: _buildQRView(context),
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
                            await qrController?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: qrController?.getFlashStatus(),
                            builder: (context, snapshot) =>
                                Text('Flash: ${snapshot.data}'),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await qrController?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: qrController?.getCameraInfo(),
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
                            await qrController?.pauseCamera();
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
                            await qrController?.resumeCamera();
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
    // final scanArea = (MediaQuery.of(context).size.width < 400 ||
    //         MediaQuery.of(context).size.height < 400)
    //     ? 150.0
    //     : 300.0;

    return QRView(
      key: qrKey,
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
      this.qrController = qrController;
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
      transitionToNextScreen(describeEnum(scanData.format), scanData.code!);
    });
  }

  Future<void> transitionToNextScreen(String type, String data) async {
    // カメラを一時停止
    qrController?.pauseCamera();
    // 次の画面へ遷移
    await Navigator.pushNamed(
      context,
      Const.routeConfirm,
      arguments: ConfirmViewArguments(type: type, data: data),
    ).then(
      // 遷移先画面から戻った場合カメラを再開
      (value) => qrController?.resumeCamera(),
    );
  }
}
