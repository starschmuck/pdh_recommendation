import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  SizedBox(
                  height: 32,
                  ),
                  TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                    labelText: 'Name',
                    fillColor: Colors.white,
                    filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                    labelText: 'E-mail',
                    fillColor: Colors.white,
                    filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ]
              ),
            )
          )
        )
      )
    );
  }
}