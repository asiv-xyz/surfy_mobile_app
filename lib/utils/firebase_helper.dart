import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter_login/twitter_login.dart';

class FirebaseHelper {
  final FirebaseAuth _auth;

  FirebaseHelper({required FirebaseAuth auth}) : _auth = auth;

  // Sign in with Email and Password
  Future<UserCredential> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<UserCredential> signInWithTwitter() async {
    final twitterLogin = new TwitterLogin(
      apiKey: 'q8gztCG4JNemnTBvlWksoZo1J',
      apiSecretKey:'d5iWbr91B6bhLUzBMbDtouHX2WG1b0DZZY64H2gfViT7ofciPq',
      redirectURI: 'surfy://'
    );

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();
    print('authResult: ${authResult.authTokenSecret}');

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );
    print('twitterAuthCredential: ${twitterAuthCredential.toString()}');

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(twitterAuthCredential);
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
  }

  // Get the current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}