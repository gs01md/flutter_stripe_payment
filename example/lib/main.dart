import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'dart:io';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Token _paymentToken;
  PaymentMethod _paymentMethod;
  String _error;
  final String _currentSecret = "pi_1Gmf3IBYSfzmQ0X0DyFndo00_secret_PS4M7ZAR3Dy0YT0vBRh0UVFlM"; //set this yourself, e.g using curl
  PaymentIntentResult _paymentIntent;
  Source _source;
  String _publishkey = "pk_test_Cy9HMsNMRIRGfs4QC4nbcVJa00BYF9YJuE";


  final SourceParamsMeta metadata = SourceParamsMeta(clientSecret: "src_client_secret_7xAWMAr4gFov9C9Msd6Fwwc1",sourceId: "src_1GmVqlBYSfzmQ0X0xKtLzU40");

  ScrollController _controller = ScrollController();

  final CreditCard testCard = CreditCard(
//    number: '4000002760003184',
    number: '4242424242424242',
    expMonth: 12,
    expYear: 21,
  );

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  initState() {
    super.initState();

//    StripePayment.setOptions(
//        StripeOptions(publishableKey: "pk_live_9sToM3y44pnZZmRcOUgK9nir00xO0zn2QR", merchantId: "Test", androidPayMode: 'test'));

    StripePayment.setOptions(
        StripeOptions(publishableKey: "pk_test_Cy9HMsNMRIRGfs4QC4nbcVJa00BYF9YJuE"));

  }

  void setError(dynamic error) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(error.toString())));
    setState(() {
      _error = error.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _source = null;
                  _paymentIntent = null;
                  _paymentMethod = null;
                  _paymentToken = null;
                });
              },
            )
          ],
        ),
        body: ListView(
          controller: _controller,
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            RaisedButton(
              child: Text("Create Source"),
              onPressed: () {
                StripePayment.createSourceWithParams(SourceParams(
                  type: 'ideal',
                  amount: 1099,
                  currency: 'eur',
                  returnURL: 'example://stripe-redirect',
                )).then((source) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${source.sourceId}')));
                  setState(() {
                    _source = source;
                  });
                }).catchError(setError);
              },
            ),
            Divider(),
            RaisedButton(
              child: Text("retrieve Source"),
              onPressed: () {
                StripePayment.retrieveSourceWithParams(SourceParams(
                  type: 'alipay',
                  metadata: metadata,
                  currency: 'eur',
                  returnURL: 'lingoaceparentapp://safepay/',
                )).then((source) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${source.sourceId}')));
                  setState(() {
                    _source = source;
                  });
                }).catchError(setError);
              },
            ),
            Divider(),
            RaisedButton(
              child: Text("Create Token with Card Form"),
              onPressed: () {
                StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
                  setState(() {
                    _paymentMethod = paymentMethod;
                  });
                }).catchError(setError);
              },
            ),
            RaisedButton(
              child: Text("Create Token with Card"),
              onPressed: () {
                StripePayment.createTokenWithCard(
                  testCard,
                ).then((token) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${token.tokenId}')));
                  setState(() {
                    _paymentToken = token;
                  });
                }).catchError(setError);
              },
            ),
            Divider(),
            RaisedButton(
              child: Text("Create Payment Method with Card"),
              onPressed: () {
                StripePayment.createPaymentMethod(
                  PaymentMethodRequest(
                    card: testCard,
                  ),
                ).then((paymentMethod) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
                  setState(() {
                    _paymentMethod = paymentMethod;
                  });
                }).catchError(setError);
              },
            ),
            RaisedButton(
              child: Text("Create Payment Method with existing token"),
              onPressed: _paymentToken == null
                  ? null
                  : () {
                      StripePayment.createPaymentMethod(
                        PaymentMethodRequest(
                          card: CreditCard(
                            token: _paymentToken.tokenId,
                          ),
                        ),
                      ).then((paymentMethod) {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${paymentMethod.id}')));
                        setState(() {
                          _paymentMethod = paymentMethod;
                        });
                      }).catchError(setError);
                    },
            ),
            Divider(),
            RaisedButton(
              child: Text("Confirm Payment Intent"),
              onPressed: _paymentMethod == null || _currentSecret == null
                  ? null
                  : () {
                      StripePayment.confirmPaymentIntent(
                        PaymentIntent(
                          clientSecret: _currentSecret,
                          paymentMethodId: _paymentMethod.id,
                        ),
                      ).then((paymentIntent) {
                        _scaffoldKey.currentState
                            .showSnackBar(SnackBar(content: Text('Received ${paymentIntent.paymentIntentId}')));
                        setState(() {
                          _paymentIntent = paymentIntent;
                        });
                      }).catchError(setError);
                    },
            ),
            RaisedButton(
              child: Text("Authenticate Payment Intent"),
              onPressed: _currentSecret == null
                  ? null
                  : () {
                      StripePayment.authenticatePaymentIntent(clientSecret: _currentSecret).then((paymentIntent) {
                        _scaffoldKey.currentState
                            .showSnackBar(SnackBar(content: Text('Received ${paymentIntent.paymentIntentId}')));
                        setState(() {
                          _paymentIntent = paymentIntent;
                        });
                      }).catchError(setError);
                    },
            ),
            Divider(),
            RaisedButton(
              child: Text("Native payment"),
              onPressed: () {
                if (Platform.isIOS) {
                  _controller.jumpTo(450);
                }
                StripePayment.paymentRequestWithNativePay(
                  androidPayOptions: AndroidPayPaymentRequest(
                    totalPrice: "1.20",
                    currencyCode: "EUR",
                  ),
                  applePayOptions: ApplePayPaymentOptions(
                    countryCode: 'DE',
                    currencyCode: 'EUR',
                    items: [
                      ApplePayItem(
                        label: 'Test',
                        amount: '13',
                      )
                    ],
                  ),
                ).then((token) {
                  setState(() {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Received ${token.tokenId}')));
                    _paymentToken = token;
                  });
                }).catchError(setError);
              },
            ),
            RaisedButton(
              child: Text("Complete Native Payment"),
              onPressed: () {
                StripePayment.completeNativePayRequest().then((_) {
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Completed successfully')));
                }).catchError(setError);
              },
            ),

            RaisedButton(
              child: Text("Change publish key"),
              onPressed: () {
                if(_publishkey == "pk_test_Cy9HMsNMRIRGfs4QC4nbcVJa00BYF9YJuE"){

                  StripePayment.setOptions(
                      StripeOptions(publishableKey: "pk_test_vMUYmBzs0sPgYjDp6w1fS7Dh00IpT8FBoa"));
                }else{

                  StripePayment.setOptions(
                      StripeOptions(publishableKey: "pk_test_Cy9HMsNMRIRGfs4QC4nbcVJa00BYF9YJuE"));
                }

              },
            ),

            Divider(),
            Text('Current source:'),
            Text(
              JsonEncoder.withIndent('  ').convert(_source?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current token:'),
            Text(
              JsonEncoder.withIndent('  ').convert(_paymentToken?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current payment method:'),
            Text(
              JsonEncoder.withIndent('  ').convert(_paymentMethod?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current payment intent:'),
            Text(
              JsonEncoder.withIndent('  ').convert(_paymentIntent?.toJson() ?? {}),
              style: TextStyle(fontFamily: "Monospace"),
            ),
            Divider(),
            Text('Current error: $_error'),
          ],
        ),
      ),
    );
  }
}
