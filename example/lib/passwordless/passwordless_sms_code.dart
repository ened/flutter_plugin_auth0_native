import 'package:auth0_native/auth0_native.dart';
import 'package:auth0_native_example/response_callback.dart';
import 'package:flutter/material.dart';

class PasswordlessSmsCode extends StatefulWidget {
  const PasswordlessSmsCode({
    Key key,
    this.listener,
    this.connection,
    this.audience,
    this.initialPhone = '',
  }) : super(key: key);

  final ResponseListener listener;
  final String connection;
  final String audience;
  final String initialPhone;

  @override
  _PasswordlessSmsCodeState createState() => _PasswordlessSmsCodeState();
}

class _PasswordlessSmsCodeState extends State<PasswordlessSmsCode> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _phoneController = TextEditingController(text: '');
  TextEditingController _codeController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();

    _phoneController.text = widget.initialPhone;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Phone Number',
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

    FocusNode().requestFocus();

    Auth0Native()
        .passwordlessWithSMS(
      _phoneController.text,
      PasswordlessType.code,
      connection: widget.connection,
    )
        .then((value) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Code has been sent.'),
      ));
    });
  }

  void _handleLogin() {
    _formKey.currentState.save();

    FocusNode().requestFocus();

    Auth0Native()
        .loginWithPhoneNumber(
      _phoneController.text,
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
