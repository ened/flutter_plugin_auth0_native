import 'package:auth0_native/auth0_native.dart';
import 'package:auth0_native_example/response_callback.dart';
import 'package:flutter/material.dart';

class PasswordlessEmailCode extends StatefulWidget {
  const PasswordlessEmailCode({
    Key key,
    this.listener,
    this.connection,
    this.audience,
    this.initialEmail = '',
  }) : super(key: key);

  final ResponseListener listener;
  final String connection;
  final String audience;
  final String initialEmail;

  @override
  _PasswordlessEmailCodeState createState() => _PasswordlessEmailCodeState();
}

class _PasswordlessEmailCodeState extends State<PasswordlessEmailCode> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController(text: '');
  TextEditingController _codeController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    _emailController.text = widget.initialEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'eMail address',
            ),
          ),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Code',
            ),
          ),
          Builder(
            builder: (context) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Send Code'),
                      onPressed: _handleSend,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: RaisedButton(
                      child: Text('Login With code'),
                      onPressed: _handleLogin,
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  void _handleSend() {
    _formKey.currentState.save();

    Auth0Native()
        .passwordlessWithEmail(_emailController.text, PasswordlessType.code,
            connection: widget.connection)
        .then((value) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Code has been sent.'),
      ));
    });
  }

  void _handleLogin() {
    _formKey.currentState.save();

    Auth0Native()
        .loginWithEmail(
      _emailController.text,
      _codeController.text,
      connection: widget.connection,
      audience: widget.audience,
    )
        .then((value) {
      widget.listener?.call(value);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Authentication done.'),
      ));
    });
  }
}
