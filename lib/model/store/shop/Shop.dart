import 'package:flutter/material.dart';

class ShopModel with ChangeNotifier {
    int _forestTypes = 1;
    int _shopNum = 1;
    bool _isDisabled = false;
    double _height = 0;
    List<Map> _forestList = [
        {"id": 1, "name": "莘莘学子林"},
        {"id": 2, "name": "相思林"},
        {"id": 3, "name": "云屯自然生态林"}
    ];

    int get forestTypes => _forestTypes;
    int get shopNum => _shopNum;
    List<Map> get forestList => _forestList;
    bool get isDisabled => _isDisabled;
    double get height => _height;
    void setForestTypes (int val) {
        this._forestTypes = val;
        notifyListeners();
    }

    void setShopNum (int num) {
        if (num < 1) {
            return null;
        }
        this._shopNum = num;
        notifyListeners();
    }

    void setForestList (List<Map> forestList) {
        this._forestList = forestList;
        notifyListeners();
    }
    void changeIsDisabled (bool isDisabled) {
        this._isDisabled = isDisabled;
        notifyListeners();
    }

    void reset () {
        this._forestList = [];
        this._shopNum = 1;
        this._isDisabled = false;
        notifyListeners();
    }
    void setHeight (double height) {
        this._height = height;
        notifyListeners();
    }
}