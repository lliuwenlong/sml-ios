import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/CommonHandler.dart';
import '../../model/store/user/User.dart';
import '../../services/ScreenAdaper.dart';
import '../../components/AppBarWidget.dart';
import '../../model/api/shop/WoodApiModel.dart';
import '../../model/store/shop/Shop.dart';
import '../Shop/Purchase.dart';
import '../../common/HttpUtil.dart';
import '../../components/LoadingSm.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import '../../common/Config.dart';
import '../../common/HttpUtil.dart';
class ShenmuDetails extends StatefulWidget {
    final Map arguments;
    ShenmuDetails({Key key, this.arguments}) : super(key: key);
    _ShenmuDetailsState createState() => _ShenmuDetailsState(arguments: this.arguments);
}

class _ShenmuDetailsState extends State<ShenmuDetails> {
    final Map arguments;
    HttpUtil http = HttpUtil();
    _ShenmuDetailsState({this.arguments});
    GlobalKey _globalKey = GlobalKey();
    double height = 0;
    List<Map> bannerList = [
        {
        "url": 'http://img.pconline.com.cn/images/upload/upc/tx/photoblog/1411/14/c2/40920783_40920783_1415949861822_mthumb.jpg'
        },
        {"url": 'http://img.juimg.com/tuku/yulantu/110126/292-11012613321981.jpg'},
        {
        "url":
            'http://img.pconline.com.cn/images/upload/upc/tx/photoblog/1411/14/c2/40920783_40920783_1415949861822_mthumb.jpg'
        },
        {"url": 'http://img.juimg.com/tuku/yulantu/110126/292-11012613321981.jpg'}
    ];
    Data data;
    bool isLoading = true;
    @override
    void initState() {
        super.initState();
        this._getData();
        wechatPayListen(success: this.nav, cancel: () {
            setState(() {
                Provider.of<ShopModel>(context).changeIsDisabled(false);
            });
        });
    }
    void _getData () async {
        final respones = await HttpUtil().get("/api/v1/wood/${arguments["id"]}");
        if (respones["code"] == 200) {
            final WoodApiModel res = new WoodApiModel.fromJson(respones);
            setState(() {
                this.data = res.data;
                this.isLoading = false;
            });
        }
    }

    BuildContext _selfContext;

    _purchase () {
        Provider.of<ShopModel>(context).reset();
		showModalBottomSheet(
			context: context,
			shape:  RoundedRectangleBorder(
				borderRadius: BorderRadius.only(
					topLeft: Radius.circular(ScreenAdaper.width(10)),
					topRight: Radius.circular(ScreenAdaper.width(10)),
				)
			),
			builder: (BuildContext context) {
				return Purchase(
                    id: this.data.woodId,
                    price: double.parse(this.data.price),
                    baseid: widget.arguments["baseid"],
                    type: widget.arguments["type"],
                    onPay: (String type, int number, int forestTypes) {
                        this.onPay(type, number, widget.arguments["baseid"], forestTypes);
                    }
                );
			}
		).then((a) {
            Provider.of<ShopModel>(context).setHeight(0);
        });
	}

    onPay (String type, int number, int id, int forestTypes) async {
        int userId = Provider.of<User>(context).userId;
        Map res = await this.http.post(type == "wx"
            ? "/api/v12/wxpay/unifiedorder"
            : "/api/v12/alipay/unifiedorder", params: {
                "wood": {
                    "channel": "Wechat",
                    "num": number,
                    "platform": Platform.isAndroid ? "Android" : "IOS",
                    "tradeType": "APP",
                    "userId": userId,
                    "woodId": widget.arguments["id"],
                    "districtId": forestTypes
                },
                "goodsType": "tree"
            });
        print(res);
        if (res["code"] == 200) {
            if (type == "wx") {
                var data = jsonDecode(res["data"]);
                Map<String, String> payInfo = {
                    "appid":"wxa22d7212da062286",
                    "partnerid": data["partnerid"],
                    "prepayid": data["prepayid"],
                    "package": "Sign=WXPay",
                    "noncestr": data["noncestr"],
                    "timestamp": data["timestamp"],
                    "sign": data["sign"].toString()
                };
                try  {
                    await wechatPay(payInfo, success: this.nav);
                    Provider.of<ShopModel>(context).changeIsDisabled(false);
                } catch (e) {
                    print('微信' + e);
                    Provider.of<ShopModel>(context).changeIsDisabled(false);
                }
            } else {
                try {
                    await tobiasPay(res["data"], success: this.nav);
                    Provider.of<ShopModel>(context).changeIsDisabled(false);
                } catch (e) {
                    print('支付宝' + e);
                }
            }
        }
    }

    nav () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/order'); 
    }

    @override
    Widget build(BuildContext context) {
        ScreenAdaper.init(context);
        print(Provider.of<ShopModel>(context).height);
        this._selfContext = context;
        return Scaffold(
            appBar: AppBarWidget().buildAppBar('神木详情'),
            bottomSheet: Container(
                width: double.infinity,
                height: ScreenAdaper.height(110) + MediaQueryData.fromWindow(window).padding.bottom,
                padding: EdgeInsets.only(
                    bottom: MediaQueryData.fromWindow(window).padding.bottom + ScreenAdaper.height(10),
                    top: ScreenAdaper.height(10),
                    left: ScreenAdaper.width(30),
                    right: ScreenAdaper.width(30)
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 1)
                    ]
                ),
                child: RaisedButton(
                    child: Text(
                        '购买',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenAdaper.fontSize(40)
                        )
                    ),
                    disabledColor: Color(0XFF86d4ca),
                    splashColor: Color.fromARGB(0, 0, 0, 0),
                    highlightColor: Color(0xff009a8a),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5))
                    ),
                    color: Color(0XFF22b0a1),
                    onPressed: (){
                        this._purchase();
                    },
                )
            ),
            body: isLoading ? Loading() : Container(
                padding: EdgeInsets.only(
                    bottom: Platform.isIOS
                        ? Provider.of<ShopModel>(context).height
                        : 0
                ),
                child: InAppWebView(
                    initialUrl: "${Config.WEB_URL}/app/#/shopTreeDetail?sid=${arguments['id']}",
                )
            )
        );
    }
}
