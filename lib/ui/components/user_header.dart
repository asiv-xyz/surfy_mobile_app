import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key, required this.profileImageUrl, required this.profileName});

  final String profileImageUrl;
  final String profileName;

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl == "" || profileName == "") {
      return Container();
    }

    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(profileImageUrl, width: 48, height: 48,)
                  )
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${profileName}', style: GoogleFonts.sora(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white)),
                    Text('Welcome to SURFY!', style: GoogleFonts.sora(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white))
                  ],
                )
              ],
            )
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  context.push('/settings');
                },
                icon: Icon(Icons.settings_outlined, color: Colors.white, size: 24)),
              SizedBox(width: 20),
              Image.asset('assets/images/ic_camera.png', width: 24, height: 24)
            ],
          )
        ],
      )
    );
  }
  
}