import 'package:ed_eureka/services/initialization.dart';
import 'package:ed_eureka/services/shared_prefs.dart';
import 'package:ed_eureka/ui/pages/authentication/login_screen.dart';
import 'package:ed_eureka/ui/pages/navmenu/menu_dashboard_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ContinueButton extends StatefulWidget {
  final Function callBack;
  ContinueButton({this.callBack});

  @override
  _ContinueButtonState createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool isLoading = false;

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: 50),
          color: Color(0xFFFFFFFF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              isLoading
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CircularProgressIndicator())
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                            fontFamily: 'Red Hat Display',
                            fontSize: 16,
                            color: Color(0xff0a0a46),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            bool userId = await LocalUserData.getUserIdKey();
            userId == null ? userId = false : userId = userId;
            Map updateInfo;
            if (userId) {
              await Initialize.getUpdateInfo();
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          MenuDashboardLayout(updateInfo: updateInfo)),
                  (Route<dynamic> route) => false);
            } else {
              List countriesList;
              countriesList = await Initialize.countryCodeGenerator();
              if (countriesList != []) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(
                              countriesList: countriesList,
                            )));
              } else {
                widget.callBack(true);
                setState(() {});
              }
            }
            /*setState(() {
              isLoading = false;
            });*/
          }),
    );
  }
}
