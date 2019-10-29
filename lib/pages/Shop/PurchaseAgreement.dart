import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:sml_ios/common/Config.dart';
import 'package:sml_ios/components/AppBarWidget.dart';
import 'package:sml_ios/services/ScreenAdaper.dart';
class PurchaseAgreement extends StatelessWidget {
    PurchaseAgreement({Key key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        ScreenAdaper.init(context);
        return Scaffold(
            appBar: AppBarWidget().buildAppBar("购买协议"),
            body: Container(
                child: InAppWebView(
                    initialUrl: "${Config.WEB_URL}/app/#/Agreement",
                )
            ),
        );
    }
}