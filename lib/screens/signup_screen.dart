import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Create user in Firebase Auth.
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        // Save additional user info to Firestore, including:
        // - username: the username provided by the user (their social media handle)
        // - name: the actual full name of the user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
              'username': _usernameController.text.trim(),
              'email': _emailController.text.trim(),
              'password_hash':
                  'handled_by_firebase', // Firebase manages password security.
              'name': _nameController.text.trim(),
              'average_duration_at_pdh': 0.0, // Default initial value.
              'isStaff': false, // Default value for isStaff.
            });

        // After successful signup, update the app state (e.g., navigate to home).
        Navigator.of(context).pop; // Close the signup page.
        // Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Handle errors such as weak password or email already in use.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed.
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    // Username Field (social media handle)
                    TextFormField(
                      controller: _usernameController,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        // Add any specific username validations here.
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Full Name Field
                    TextFormField(
                      controller: _nameController,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // Add additional email validation if needed.
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _signup,
                          child: Text('Sign Up'),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.of(context).pop(context);
        },
        child: Icon(Icons.arrow_back),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
