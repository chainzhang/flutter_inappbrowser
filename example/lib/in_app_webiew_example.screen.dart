import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class Foo {
  String bar;
  String baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {'bar': this.bar, 'baz': this.baz};
  }
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    HttpAuthCredentialDatabase.instance().clearAllAuthCredentials();
//
//    HttpAuthCredentialDatabase.instance().getHttpAuthCredentials(ProtectionSpace(host: "192.168.1.20", protocol: "http", realm: "Node", port: 8081)).then((credentials) {
//      for (var credential in credentials )
//        print("\n\nCREDENTIAL: ${credential.username} ${credential.password}\n\n");
//    });
//    HttpAuthCredentialDatabase.instance().getAllAuthCredentials().then((result) {
//      for (var r in result) {
//        ProtectionSpace protectionSpace = r["protectionSpace"];
//        print("\n\nProtectionSpace: ${protectionSpace.protocol} ${protectionSpace.host}:");
//        List<HttpAuthCredential> credentials = r["credentials"];
//        for (var credential in credentials)
//          print("\tCREDENTIAL: ${credential.username} ${credential.password}");
//      }
//    });
//    HttpAuthCredentialDatabase.instance().setHttpAuthCredential(ProtectionSpace(host: "192.168.1.20", protocol: "http", realm: "Node", port: 8081), HttpAuthCredential(username: "user 1", password: "password 1"));
//    HttpAuthCredentialDatabase.instance().setHttpAuthCredential(ProtectionSpace(host: "192.168.1.20", protocol: "http", realm: "Node", port: 8081), HttpAuthCredential(username: "user 2", password: "password 2"));

    return Scaffold(
        appBar: AppBar(
            title: Text(
          "InAppWebView",
        )),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('flutter_inappbrowser example'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('InAppBrowser'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/InAppBrowser');
                },
              ),
              ListTile(
                title: Text('ChromeSafariBrowser'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ChromeSafariBrowser');
                },
              ),
              ListTile(
                title: Text('InAppWebView'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
        body: Container(
            child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
                "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
          ),
          Container(
              padding: EdgeInsets.all(10.0),
              child: progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container()),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              child: InAppWebView(
                //initialUrl: "https://www.youtube.com/embed/M7lc1UVf-VE?playsinline=1",
                //initialUrl: "https://github.com",
                //initialUrl: "chrome://safe-browsing/match?type=malware",
                //initialUrl: "http://192.168.1.20:8081/",
                //initialUrl: "https://192.168.1.20:4433/",
                initialFile: "assets/index.html",
                initialHeaders: {},
                initialOptions: InAppWebViewWidgetOptions(
                  inAppWebViewOptions: InAppWebViewOptions(
                      //disableVerticalScroll: false,
                      //disableHorizontalScroll: false,
                      debuggingEnabled: true,
                      clearCache: true,
                      //useShouldOverrideUrlLoading: true,
                      useOnTargetBlank: true,
                      //useOnLoadResource: true,
                      //useOnDownloadStart: true,
                      //useShouldInterceptAjaxRequest: true,
                      //useShouldInterceptFetchRequest: true,
                      //preferredContentMode: InAppWebViewUserPreferredContentMode.DESKTOP,
                      resourceCustomSchemes: [
                        "my-special-custom-scheme"
                      ],
                      contentBlockers: [
                        ContentBlocker(
                            trigger: ContentBlockerTrigger(
                                urlFilter: ".*",
                                resourceType: [
                                  ContentBlockerTriggerResourceType.IMAGE,
                                  ContentBlockerTriggerResourceType.STYLE_SHEET
                                ],
                                ifTopUrl: [
                                  "https://getbootstrap.com/"
                                ]),
                            action: ContentBlockerAction(
                                type: ContentBlockerActionType.BLOCK))
                      ]),
                  androidInAppWebViewOptions: AndroidInAppWebViewOptions(
                    databaseEnabled: true,
                    domStorageEnabled: true,
                    geolocationEnabled: true,
                    safeBrowsingEnabled: true,
                    //blockNetworkImage: true,
                  ),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;

                  if (Platform.isAndroid) webView.startSafeBrowsing();

                  webView.addJavaScriptHandler(
                      handlerName: 'handlerFoo',
                      callback: (args) {
                        return new Foo(bar: 'bar_value', baz: 'baz_value');
                      });

                  webView.addJavaScriptHandler(
                      handlerName: 'handlerFooWithArgs',
                      callback: (args) {
                        print(args);
                        return [
                          args[0] + 5,
                          !args[1],
                          args[2][0],
                          args[3]['foo']
                        ];
                      });
                },
                onLoadStart: (InAppWebViewController controller, String url) {
                  print("started $url");
                  setState(() {
                    this.url = url;
                  });
                },
                onLoadStop: (InAppWebViewController controller, String url) async {
                  print("stopped $url");
                  if (Platform.isAndroid) {
                    controller.clearSslPreferences();
                    controller.clearClientCertPreferences();
                  }
                  //controller.findAllAsync("flutter");
                  print(await controller.getFavicons());
                  print(await CookieManager.instance().getCookies(url: url));
                  //await CookieManager.instance().setCookie(url: url, name: "myCookie", value: "myValue");
                  //print(await CookieManager.instance().getCookies(url: url));
                  //await Future.delayed(const Duration(milliseconds: 2000));
                  //controller.scrollTo(x: 0, y: 500);
                  //await Future.delayed(const Duration(milliseconds: 2000));
                  //controller.scrollBy(x: 0, y: 150);
                },
                onScrollChanged: (InAppWebViewController controller, int x, int y) {
                  //print("\nSCROLLED\n");
                },
                onLoadError: (InAppWebViewController controller, String url,
                    int code, String message) async {
                  print("error $url: $code, $message");

                  var tRexHtml = await controller.getTRexRunnerHtml();
                  var tRexCss = await controller.getTRexRunnerCss();

                  controller.loadData(data: """
                  <html>
                    <head>
                      <meta charset="utf-8">
                      <meta name="viewport" content="width=device-width, initial-scale=1.0,maximum-scale=1.0, user-scalable=no">
                      <style>$tRexCss</style>
                    </head>
                    <body>
                      $tRexHtml
                      <p>
                        URL $url failed to load.
                      </p>
                      <p>
                        Error: $code, $message
                      </p>
                    </body>
                  </html>
                  """);
                },
                onLoadHttpError: (InAppWebViewController controller, String url,
                    int statusCode, String description) async {
                  print("HTTP error $url: $statusCode, $description");
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                shouldOverrideUrlLoading:
                    (InAppWebViewController controller, String url) {
                  print("override $url");
                  controller.loadUrl(url: url);
                },
                onLoadResource: (InAppWebViewController controller,
                    LoadedResource response) {
                  print("Resource type: '" +
                      response.initiatorType +
                      "' started at: " +
                      response.startTime.toString() +
                      "ms ---> duration: " +
                      response.duration.toString() +
                      "ms " +
                      response.url);
                },
                onConsoleMessage: (InAppWebViewController controller,
                    ConsoleMessage consoleMessage) {
                  print("""
                  console output:
                    message: ${consoleMessage.message}
                    messageLevel: ${consoleMessage.messageLevel.toString()}
                  """);
                },
                onDownloadStart:
                    (InAppWebViewController controller, String url) async {
                  //              final taskId = await FlutterDownloader.enqueue(
                  //                url: url,
                  //                savedDir: await _findLocalPath(),
                  //                showNotification: true, // show download progress in status bar (for Android)
                  //                openFileFromNotification: true, // click on notification to open downloaded file (for Android)
                  //              );
                },
                onLoadResourceCustomScheme: (InAppWebViewController controller,
                    String scheme, String url) async {
                  if (scheme == "my-special-custom-scheme") {
                    var bytes = await rootBundle.load("assets/" +
                        url.replaceFirst("my-special-custom-scheme://", "", 0));
                    var response = new CustomSchemeResponse(
                        data: bytes.buffer.asUint8List(),
                        contentType: "image/svg+xml",
                        contentEnconding: "utf-8");
                    return response;
                  }
                  return null;
                },
                onTargetBlank: (InAppWebViewController controller, String url) {
                  print("target _blank: " + url);
                  controller.loadUrl(url: url);
                },
                onGeolocationPermissionsShowPrompt:
                    (InAppWebViewController controller, String origin) async {
                  GeolocationPermissionShowPromptResponse response;

                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Permission Geolocation API"),
                        content: Text("Can we use Geolocation API?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () {
                              response =
                                  new GeolocationPermissionShowPromptResponse(
                                      origin: origin,
                                      allow: false,
                                      retain: false);
                              Navigator.of(context).pop();
                            },
                          ),
                          FlatButton(
                            child: Text("Accept"),
                            onPressed: () {
                              response =
                                  new GeolocationPermissionShowPromptResponse(
                                      origin: origin,
                                      allow: true,
                                      retain: true);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );

                  return response;
                },
                onJsAlert:
                    (InAppWebViewController controller, String message) async {
                  JsAlertResponseAction action =
                      await createAlertDialog(context, message);
                  return new JsAlertResponse(
                      handledByClient: true, action: action);
                },
                onJsConfirm:
                    (InAppWebViewController controller, String message) async {
                  JsConfirmResponseAction action =
                      await createConfirmDialog(context, message);
                  return new JsConfirmResponse(
                      handledByClient: true, action: action);
                },
                onJsPrompt: (InAppWebViewController controller, String message,
                    String defaultValue) async {
                  _textFieldController.text = defaultValue;
                  JsPromptResponseAction action =
                      await createPromptDialog(context, message);
                  return new JsPromptResponse(
                      handledByClient: true,
                      action: action,
                      value: _textFieldController.text);
                },
                onSafeBrowsingHit: (InAppWebViewController controller,
                    String url, SafeBrowsingThreat threatType) async {
                  SafeBrowsingResponseAction action =
                      SafeBrowsingResponseAction.SHOW_INTERSTITIAL;
                  return new SafeBrowsingResponse(report: true, action: action);
                },
                onReceivedHttpAuthRequest: (InAppWebViewController controller,
                    HttpAuthChallenge challenge) async {
                  print(
                      "HTTP AUTH REQUEST: ${challenge.protectionSpace.host}, realm: ${challenge.protectionSpace.realm}, previous failure count: ${challenge.previousFailureCount.toString()}");

                  return new HttpAuthResponse(
                      username: "USERNAME",
                      password: "PASSWORD",
                      action: HttpAuthResponseAction
                          .PROCEED,
                      permanentPersistence: true);
                },
                onReceivedServerTrustAuthRequest:
                    (InAppWebViewController controller,
                        ServerTrustChallenge challenge) async {
                  print(
                      "SERVER TRUST AUTH REQUEST: ${challenge.protectionSpace.host}, SSL ERROR CODE: ${challenge.error.toString()}, MESSAGE: ${challenge.message}");

                  return new ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED);
                },
                onReceivedClientCertRequest: (InAppWebViewController controller,
                    ClientCertChallenge challenge) async {
                  print(
                      "CLIENT CERT REQUEST: ${challenge.protectionSpace.host}");

                  return new ClientCertResponse(
                      certificatePath: "assets/certificate.pfx",
                      certificatePassword: "",
                      androidKeyStoreType: "PKCS12",
                      action: ClientCertResponseAction.PROCEED);
                },
                onFindResultReceived: (InAppWebViewController controller,
                    int activeMatchOrdinal,
                    int numberOfMatches,
                    bool isDoneCounting) async {
                  print(
                      "Current highlighted: $activeMatchOrdinal, Number of matches found: $numberOfMatches, find operation completed: $isDoneCounting");
                },
                shouldInterceptAjaxRequest: (InAppWebViewController controller,
                    AjaxRequest ajaxRequest) async {
                  print(
                      "AJAX REQUEST: ${ajaxRequest.method} - ${ajaxRequest.url}, DATA: ${ajaxRequest.data}, headers: ${ajaxRequest.headers}");
                  if (ajaxRequest.url ==
                      "http://192.168.1.20:8082/test-ajax-post") {
                    ajaxRequest.responseType = 'json';
                    ajaxRequest.data = "firstname=Lorenzo&lastname=Pichilli";
                  }
                  //              ajaxRequest.method = "GET";
                  //              ajaxRequest.url = "http://192.168.1.20:8082/test-download-file";
                  //              ajaxRequest.headers = {
                  //                "Custom-Header": "Custom-Value"
                  //              };
                  //              return ajaxRequest;
                  return ajaxRequest;
                },
                onAjaxReadyStateChange: (InAppWebViewController controller,
                    AjaxRequest ajaxRequest) async {
                  print(
                      "AJAX READY STATE CHANGE: ${ajaxRequest.method} - ${ajaxRequest.url}, ${ajaxRequest.status}, ${ajaxRequest.readyState}, ${ajaxRequest.responseType}, ${ajaxRequest.responseText}, ${ajaxRequest.response}, ${ajaxRequest.responseHeaders}");
                  return AjaxRequestAction.PROCEED;
                },
                onAjaxProgress: (InAppWebViewController controller,
                    AjaxRequest ajaxRequest) async {
                  print(
                      "AJAX EVENT: ${ajaxRequest.method} - ${ajaxRequest.url}, ${ajaxRequest.event.type}, LOADED: ${ajaxRequest.event.loaded}, ${ajaxRequest.responseHeaders}");
                  return AjaxRequestAction.PROCEED;
                },
                shouldInterceptFetchRequest: (InAppWebViewController controller,
                    FetchRequest fetchRequest) async {
                  print(
                      "FETCH REQUEST: ${fetchRequest.method} - ${fetchRequest.url}, headers: ${fetchRequest.headers}");
                  fetchRequest.action = FetchRequestAction.ABORT;
                  print(fetchRequest.body);
                  return fetchRequest;
                },
                onNavigationStateChange:
                    (InAppWebViewController controller, String url) async {
                  print("NAVIGATION STATE CHANGE: $url");
                  setState(() {
                    this.url = url;
                  });
                },
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () {
                  if (webView != null) {
                    webView.goBack();
                  }
                },
              ),
              RaisedButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  if (webView != null) {
                    webView.goForward();
                  }
                },
              ),
              RaisedButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  if (webView != null) {
                    webView.reload();
                  }
                },
              ),
            ],
          ),
        ])));
  }

  Future<JsAlertResponseAction> createAlertDialog(
      BuildContext context, String message) async {
    JsAlertResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                action = JsAlertResponseAction.CONFIRM;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  Future<JsConfirmResponseAction> createConfirmDialog(
      BuildContext context, String message) async {
    JsConfirmResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                action = JsConfirmResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                action = JsConfirmResponseAction.CONFIRM;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  Future<JsPromptResponseAction> createPromptDialog(
      BuildContext context, String message) async {
    JsPromptResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: TextField(
            controller: _textFieldController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                action = JsPromptResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                action = JsPromptResponseAction.CONFIRM;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
