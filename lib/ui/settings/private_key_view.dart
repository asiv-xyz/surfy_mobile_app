import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';

class PrivateKeyPage extends StatelessWidget {
  const PrivateKeyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Private key')
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your key (secp256k1)', style: Theme.of(context).textTheme.displaySmall),
                Text('Supported blockchain: EVM', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14)
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: FutureBuilder<String>(
                    future: Web3AuthFlutter.getPrivKey(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                                child: Text(snapshot.data ?? "", style: Theme.of(context).textTheme.labelMedium,)
                            ),
                            const SizedBox(height: 20,),
                            TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: snapshot.data ?? ""));
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: SurfyColor.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 20)
                                ),
                                child: Text('Copy', style: Theme.of(context).textTheme.displaySmall,))
                          ],
                        );
                      }

                      return const SizedBox();
                    },
                  )
                )
              ],
            ),

            const SizedBox(height: 30,),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your key (ed25519)', style: Theme.of(context).textTheme.displaySmall,),
                Text('Supported blockchain: Solana, Tron, XRPL, Bitcoin', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 10,),
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: FutureBuilder<String>(
                      future: Web3AuthFlutter.getEd25519PrivKey(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                  child: Text(snapshot.data ?? "", style: Theme.of(context).textTheme.labelMedium,)
                              ),
                              const SizedBox(height: 20,),
                              TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: snapshot.data ?? ""));
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: SurfyColor.blue,
                                      padding: const EdgeInsets.symmetric(horizontal: 20)
                                  ),
                                  child: Text('Copy', style: Theme.of(context).textTheme.displaySmall,))
                            ],
                          );
                        }

                        return const SizedBox();
                      },
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }

}