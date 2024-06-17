import 'package:flutter/material.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              MaterialButton(
                onPressed: () {
                  Web3AuthFlutter.logout();
                  context.go('/login');
                },
                child: const Text('Logout'))
            ],
          )
        ),
      )
    );
  }
}