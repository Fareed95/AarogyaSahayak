import 'login_screen.dart';
import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

          body: Column(
            children: [ElevatedButton(onPressed: ()=>{Navigator.push(context, MaterialPageRoute(builder: (context) => login_screen(),))}, child: Text('Login')),
              ElevatedButton(onPressed: ()=>{Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              )}, child: Text('Notification')),
            ]
          ),
    );
  }
}
