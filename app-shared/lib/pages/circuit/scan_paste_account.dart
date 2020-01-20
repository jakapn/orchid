import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orchid/api/orchid_vpn_config.dart';
import 'package:orchid/api/qrcode.dart';
import 'package:orchid/api/user_preferences.dart';
import 'package:orchid/pages/app_sizes.dart';
import 'package:orchid/pages/app_text.dart';
import 'package:orchid/pages/common/dialogs.dart';
import 'package:orchid/pages/common/formatting.dart';
import 'package:flutter/services.dart';

typedef ImportAccountCompletion = void Function(
    ParseOrchidAccountResult result);

class ScanOrPasteOrchidAccount extends StatefulWidget {
  final ImportAccountCompletion onImportAccount;
  final double spacing;

  const ScanOrPasteOrchidAccount(
      {Key key, @required this.onImportAccount, this.spacing})
      : super(key: key);

  @override
  _ScanOrPasteOrchidAccountState createState() =>
      _ScanOrPasteOrchidAccountState();
}

class _ScanOrPasteOrchidAccountState extends State<ScanOrPasteOrchidAccount> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var showIcons = screenWidth >= AppSizes.iphone_xs.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildButton(
              text: "Scan",
              trailing: showIcons ?
                  Image.asset("assets/images/scan.png", color: Colors.white) : SizedBox(),
              textColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              onPressed: _scanQRCode),
          padx(widget.spacing ?? 24),
          _buildButton(
              text: "Paste",
              trailing: showIcons ? Icon(Icons.content_paste, color: Colors.deepPurple) : SizedBox(),
              textColor: Colors.deepPurple,
              backgroundColor: Colors.white,
              onPressed: _pasteCode),
        ],
      ),
    );
  }

  Widget _buildButton(
      {String text,
      Widget trailing,
      Color textColor,
      Color backgroundColor,
      @required VoidCallback onPressed}) {
    return FlatButton(
      color: backgroundColor,
      onPressed: onPressed,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.deepPurple, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
        child: Row(
          children: <Widget>[
            AppText.body(
                text: text,
                color: textColor,
                letterSpacing: 1.25,
                lineHeight: 1.14),
            padx(4),
            trailing
          ],
        ),
      ),
    );
  }

  void _scanQRCode() async {
    ParseOrchidAccountResult parseAccountResult;
    try {
      String text = await QRCode.scan();
      parseAccountResult = await _parseConfig(context, text);
    } catch (err) {
      print("error parsing scanned orchid account: $err");
    }
    if (parseAccountResult != null) {
      widget.onImportAccount(parseAccountResult);
    } else {
      _scanQRCodeError();
    }
  }

  void _pasteCode() async {
    ParseOrchidAccountResult parseAccountResult;
    try {
      ClipboardData data = await Clipboard.getData('text/plain');
      String text = data.text;
      try {
        parseAccountResult = await _parseConfig(context, text);
      } catch (err) {
        print("error parsing pasted orchid account: $err");
      }
    } catch (err) {
      print("error parsing pasted orchid account: $err");
    }
    if (parseAccountResult != null) {
      widget.onImportAccount(parseAccountResult);
    } else {
      _pasteCodeError();
    }
  }

  void _scanQRCodeError() {
    Dialogs.showAppDialog(
        context: context,
        title: "Invalid QR Code",
        bodyText:
            "The QR code you scanned does not contain a valid account configuration.");
  }

  void _pasteCodeError() {
    Dialogs.showAppDialog(
        context: context,
        title: "Invalid Code",
        bodyText:
            "The code you pasted does not contain a valid account configuration.");
  }

  Future<ParseOrchidAccountResult> _parseConfig(
      BuildContext context, String config) async {
    var existingKeys = await UserPreferences().getKeys();
    return OrchidVPNConfig.parseOrchidAccount(config, existingKeys);
  }
}