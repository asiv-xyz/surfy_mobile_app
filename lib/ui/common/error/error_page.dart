import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  LottieBuilder.asset("assets/images/animation_error.json", width: 150),
                  const SizedBox(height: 10,),
                  Text("Something was wrong!", style: Theme.of(context).textTheme.displaySmall),
                ],
              )
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: SurfyColor.blue,
                padding: EdgeInsets.symmetric(vertical: 20)
              ),
              child: Container(
                child: Center(
                  child: Text('Back to Home', style: Theme.of(context).textTheme.displaySmall)
                ),
              ))
          ],
        )
      )
    );
  }

}