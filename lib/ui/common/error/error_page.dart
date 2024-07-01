import 'package:flutter/material.dart';

class ErrorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ErrorPageState();
  }
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Error')
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [

          ],
        )
      )
    );
  }

}