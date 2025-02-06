import 'package:flutter/material.dart';
import 'package:order_control/complements/storage/storage.dart';
import 'package:order_control/views/home/home.dart';
import 'package:order_control/views/login_view/login.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    final SecureStorage _storage = SecureStorage();
    // ignore: non_constant_identifier_names
    String login_verification = "";



    @override
  void initState() {
    
    super.initState();
    checkCredentials();
  }
  Future<void> checkCredentials() async {
    String data = await _storage.readSecureData("token") ?? "";

   
    
    setState(() {
      login_verification = data;
     
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: login_verification!=""?const Home():const Login(),
    );
  }
}