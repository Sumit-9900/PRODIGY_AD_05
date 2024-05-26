import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/screens/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey key = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    await controller!.resumeCamera();
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen(
      (barcode) {
        setState(() {
          this.barcode = barcode;
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultScreen(controller: barcode.code),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: key,
            onQRViewCreated: onQRViewCreated,
            overlay: QrScannerOverlayShape(
              cutOutHeight: 300,
              cutOutWidth: 300,
              borderWidth: 8.0,
              borderColor: Colors.greenAccent,
              borderRadius: 10,
              overlayColor: const Color.fromRGBO(0, 0, 0, 80),
            ),
          ),
          Positioned(
            top: 10,
            right: 150,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(163, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller!.toggleFlash();
                      });
                    },
                    icon: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Icon(
                            snapshot.data! ? Icons.flash_on : Icons.flash_off,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        controller!.flipCamera();
                      });
                    },
                    icon: FutureBuilder(
                      future: controller?.getCameraInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.data == CameraFacing.back) {
                          return const Icon(Ionicons.camera);
                        } else if (snapshot.data == CameraFacing.front) {
                          return const Icon(Ionicons.camera_reverse);
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
