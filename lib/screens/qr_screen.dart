import 'package:flutter/material.dart';
import 'package:guarappwebbilheteria/src/qr_code_scanner_web.dart';

class QrScreen extends StatefulWidget
{
  final TextEditingController fieldController;
  QrScreen(this.fieldController);

  @override
  _QrScreenState createState() => _QrScreenState(fieldController);
}

class _QrScreenState extends State<QrScreen>
{
  final TextEditingController fieldController;
  _QrScreenState(this.fieldController);

  bool done = false;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        centerTitle: true,
        title: Text('Ler QR Code'),
      ),
      body: QrCodeCameraWeb(qrCodeCallback: (qr)
      {
        if (qr != null && qr != '' && !done)
        {
          done = true;
          fieldController.text = qr.toString();
          Navigator.of(context).pop();
        }
      }),
    );
  }
}
