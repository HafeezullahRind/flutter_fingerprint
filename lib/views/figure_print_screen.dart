import 'package:figureprint_app/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class FigurePrintScreen extends StatefulWidget {
  const FigurePrintScreen({Key? key}) : super(key: key);

  @override
  _FigurePrintScreenState createState() => _FigurePrintScreenState();
}

class _FigurePrintScreenState extends State<FigurePrintScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.toString()}';
      });
      return;
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
    if (authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: _authenticate, // Call _authenticate on tap
              child: Center(
                child: Image.asset(
                  'images/figureprint-removebg-preview.png',
                  color: Colors.blueAccent,
                  height: 100,
                ),
              ),
            ),
            // const SizedBox(height: 20),
            // if (_canCheckBiometrics)
            //   ElevatedButton(
            //     onPressed: _authenticate,
            //     child: const Text('Authenticate with Fingerprint'),
            //   )
            // else
            //   const Text('Fingerprint authentication is not available'),
            const SizedBox(height: 20),
            Text('Status: $_authorized'),
          ],
        ),
      ),
    );
  }
}
