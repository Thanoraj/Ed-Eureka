import 'package:ed_eureka/services/user_management.dart';
import 'package:flutter/material.dart';

class NotConnectedAlert extends StatefulWidget {
  const NotConnectedAlert({
    Key key,
    this.notConnected,
    this.content,
    this.title,
    this.func,
    this.icon,
  }) : super(key: key);
  final icon;
  final bool notConnected;
  final String title;
  final String content;
  final func;

  @override
  _NotConnectedAlertState createState() => _NotConnectedAlertState();
}

class _NotConnectedAlertState<T extends NotConnectedAlert> extends State<T> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: widget.notConnected == null ? true : widget.notConnected,
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(10),
            elevation: 5,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.icon == null
                            ? Icons.signal_wifi_connected_no_internet_4
                            : widget.icon),
                        Container(
                          padding:
                              EdgeInsets.only(left: 10, top: 30, bottom: 25),
                          child: Text(
                            widget.title == null
                                ? 'Not Connected'
                                : widget.title,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ]),
                  Divider(
                    thickness: 0.75,
                    indent: 15,
                    endIndent: 15,
                    color: Colors.black,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 25,
                      left: 25,
                      right: 25,
                    ),
                    child: Text(
                      widget.content == null
                          ? 'You Are Not Connected to internet. Please connect to internet and try again'
                          : widget.content,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: widget.func == null
                        ? () {
                            Navigator.pop(context);
                          }
                        : () {
                            UserManagement.signOut(context);
                          },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      child: Text('Ok'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class SignOutEvent extends NotConnectedAlert {
  SignOutEvent()
      : super(
          title: 'Signing Out',
          content:
              'Your account has been signed in in a another device. If you haven\'t signed in please reset your password',
          func: 'func',
        );
  @override
  SignOutEventState createState() => SignOutEventState();
}

class SignOutEventState extends _NotConnectedAlertState<SignOutEvent> {
  @override
  void dispose() {
    UserManagement.signOut(context);
    super.dispose();
  }
}
