import 'package:auth0_native/auth0_native.dart';
import 'package:auth0_native_example/response_callback.dart';
import 'package:flutter/material.dart';

class PasswordlessEmailLink extends StatefulWidget {
  const PasswordlessEmailLink({
    Key key,
    this.listener,
    this.connection,
    this.initialEmail = '',
  }) : super(key: key);

  final ResponseListener listener;
  final String connection;
  final String initialEmail;

  @override
  _PasswordlessEmailLinkState createState() => _PasswordlessEmailLinkState();
}

class _PasswordlessEmailLinkState extends State<PasswordlessEmailLink> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController(text: '');

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
          Builder(
            builder: (context) {
              return Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      child: Text('Send me a Link'),
                      onPressed: () {
                        _formKey.currentState.save();

                        Auth0Native()
                            .passwordlessWithEmail(
                          _emailController.text,
                          PasswordlessType.webLink,
                          connection: widget.connection,
                        )
                            .then((value) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Link has been sent.'),
                          ));
                        });
                      },
                    ),
                  ),
                  // SizedBox(width: 5),
                  // Expanded(
                  //   child: RaisedButton(
                  //     child: Text('Login With code'),
                  //     onPressed: () {
                  //       _passwordlessEmailLoginFormKey.currentState.save();

                  //       Auth0Native()
                  //           .loginWithEmail(
                  //               _emailcontroller.text, _codeController.text,
                  //               connection: widget.emailConnection)
                  //           .then((value) {
                  //         widget.listener?.call(value);
                  //         Scaffold.of(context).showSnackBar(SnackBar(
                  //           content: Text('Authentication done.'),
                  //         ));
                  //       });
                  //     },
                  //   ),
                  // ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
