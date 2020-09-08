import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guarappwebbilheteria/screens/info_screen.dart';

class LoginScreen extends StatefulWidget
{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<FirebaseUser> getUser(email, password) async
  {
    final AuthResult result = await _auth.signInWithEmailAndPassword
      (email: email, password: password);
    final FirebaseUser user = result.user;

    assert(user != null);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return user;
  }

  void logIn()
  {
    BuildContext auxContext;

    showDialog
    (
      context: context,
      builder: (context)
      {
        auxContext = context;
        return Center(child: CircularProgressIndicator());
      }
    );

    getUser(emailController.text, passwordController.text)
      .then((FirebaseUser user)
      {
        Navigator.of(auxContext).pop();
        Navigator.push(context, new MaterialPageRoute(builder: (context) => InfoScreen(user)));
      }).catchError((e)
      {
        Navigator.of(auxContext).pop();
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(SnackBar(content: Text('Usuário ou senha incorretos')));
      });
    passwordController.text = '';
  }

  @override
  Widget build(BuildContext context)
  {
    double width = MediaQuery.of(context).size.width;

    Widget body()
    {
      return Form
        (
        child: ListView
          (
          children: <Widget>
          [
            Container
            (
              width: width > 400 ? 400 : width,
              child: TextFormField
              (
                controller: emailController,
                decoration: InputDecoration(hintText: "E-mail"),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 10),
            Container
            (
              width: width > 400 ? 400 : width,
              child: TextFormField
              (
                controller: passwordController,
                decoration: InputDecoration(hintText: "Senha"),
                obscureText: true,
                onFieldSubmitted: (value) => logIn(),
              ),
            ),
            SizedBox(height: 10),
            FlatButton
            (
              color: Colors.blue,
              onPressed: () => logIn(),
              child: Container
              (
                alignment: Alignment.center,
                width: width > 400 ? 400 : width,
                child: Text('Entrar', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );
    }

    return Scaffold
    (
      appBar: AppBar(title: Text('Bilheteria'), centerTitle: true),
      body: Container
      (
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: body()
      ),
    );
  }
}
