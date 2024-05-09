import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;
import 'package:wghdfm_java/networking/api_service_class.dart';

class PayPalConfig {
  PayPalConfig({
    this.clientId,
    this.secret,
    this.production,
    this.paymentMethodId,
    this.enabled,
  });

  String? clientId;
  String? secret;
  bool? production;
  String? paymentMethodId;
  bool? enabled;

  PayPalConfig copyWith({
    String? clientId,
    String? secret,
    bool? production,
    String? paymentMethodId,
    bool? enabled,
  }) =>
      PayPalConfig(
        clientId: clientId ?? this.clientId,
        secret: secret ?? this.secret,
        production: production ?? this.production,
        paymentMethodId: paymentMethodId ?? this.paymentMethodId,
        enabled: enabled ?? this.enabled,
      );

  factory PayPalConfig.fromRawJson(String str) =>
      PayPalConfig.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PayPalConfig.fromJson(Map<String, dynamic> json) => PayPalConfig(
        clientId: json["clientId"] == null ? null : json["clientId"],
        secret: json["secret"] == null ? null : json["secret"],
        production: json["production"] == null ? null : json["production"],
        paymentMethodId:
            json["paymentMethodId"] == null ? null : json["paymentMethodId"],
        enabled: json["enabled"] == null ? null : json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "clientId": clientId == null ? null : clientId,
        "secret": secret == null ? null : secret,
        "production": production == null ? null : production,
        "paymentMethodId": paymentMethodId == null ? null : paymentMethodId,
        "enabled": enabled == null ? null : enabled,
      };
}

/// Http client holding a username and password to be used for Basic authentication
class BasicAuthClient extends http.BaseClient {
  /// The username to be used for all requests
  final String username;

  /// The password to be used for all requests
  final String password;

  final http.Client _inner;
  final String _authString;

  /// Creates a client wrapping [inner] that uses Basic HTTP auth.
  ///
  /// Constructs a new [BasicAuthClient] which will use the provided [username]
  /// and [password] for all subsequent requests.
  BasicAuthClient(this.username, this.password, {http.Client? inner})
      : _authString = _getAuthString(username, password),
        _inner = inner ?? http.Client();

  static String _getAuthString(String username, String password) {
    final token = base64.encode(latin1.encode('$username:$password'));

    final authstr = 'Basic ' + token.trim();

    return authstr;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['Authorization'] = _authString;

    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

class PaypalServices {
  static var isProductionReady = true;
  String? accessToken;

  ///MY Details
  // static String clientIDnew = "AciWaLkmkTS70sR9T4UINLYjl9v8UUvewaNe7mnYgfsJOk3TxtOtAz0t74YUo_2NynkQu6lWmUdR8VPG";
  // static String secretNew = "EIsxh62P6Bo_kbvdcOyYlZLYiwLNlzgF7mKba8naqIN-oZ03Ua7sGmsz0t74YUo_2NynkQu6lWmUdR8VPG";

  static String SoundboxclientIDnew =
      "AbVAI9Yhg-fJCQbN3y8GtBBJTksvpSqbAgG0kpZNF00fO0sKsDXKT08a5pneNaFhEs6M22V6eA6ozIa3";
  static String SoundboxsecretNew =
      "EIzgALmZavJ6gaNli2oVxpa3AhRcjXAHL55nIbBSmw4Pb4ahddb-yIeBSEZBr1P_zvktxy0wFs8Bk_Y5";

  ///Client details
  // static String clientIDnew = "AciWaLkmkTS70sR9T4UINLYjl9v8UUvewaNe7mnYgfsJOk3TxtOtAz0t74YUo_2NynkQu6lWmUdR8VPG";
  // static String secretNew = "EIsxh62P6Bo_kbvdcOyYlZLYiwLNlzgF7mKba8naqIN-oZ03Ua7sGmsz0t74YUo_2NynkQu6lWmUdR8VPG";
  //
  // static String clientIDnew2 = "AZTy-RB9AXFzhWRGBMQsn1OL8Tjnc2YtYpECY0cEI87RQ8FZXJDHma5t4wUOv2bLKqNRPaWa2alsAtAR";
  // static String secretNew2 = "EBEm1ebLDcgW8Ss77y7FJYLWWcOHJODzuos-iLP8mPo9uZIEkx42uxUf6SyD3zerBcXj8GNwlkK2byPN";
  //
  // ///Soundbox APIS
  // static String SoundboxclientIDnew = "AQ40ngOwu9EQjoR3JAYQn6jxSlSlcUqagOYRX4NabS07Wv0VBNzeAWfgvQ7Q2Iq1CsjesoxSVwA7CalK";
  // static String SoundboxsecretNew = "EI_rmtZ1d5APsaSRty3R2cBnn0oR7Kiyy85i5sPrzQvHf21RuEYKtgyqcBMvV3fQnbLwo_cLcN9vOt_p";
  //
  // static String SoundboxclientIDnew2 = "AQK7mxS-t6zwvLbEIwcCePOUObK4yt_UiZYwzkD14tsMqOPNuiKlMvRHyeKb_ZpmBdSdvI5w4-jCedPs";
  // static String SoundboxsecretNew2 = "ENNpAW2FQAnVHvGd3VX9oN2rM-nL8BZ9zsGnSQhx2kmkTl77ZqIOHOcrIu56lJcVfN35Qae07sfF4p4b";

  String domain = isProductionReady
      ? 'https://api.paypal.com'
      : 'https://api.sandbox.paypal.com';

  Future<String> getAccessToken() async {
    var json = isProductionReady
        ? '{"clientId":"AZTy-RB9AXFzhWRGBMQsn1OL8Tjnc2YtYpECY0cEI87RQ8FZXJDHma5t4wUOv2bLKqNRPaWa2alsAtAR","secret":"EBEm1ebLDcgW8Ss77y7FJYLWWcOHJODzuos-iLP8mPo9uZIEkx42uxUf6SyD3zerBcXj8GNwlkK2byPN","production":true,"paymentMethodId":"paypal","enabled":true}'
        : '{"clientId":"AQK7mxS-t6zwvLbEIwcCePOUObK4yt_UiZYwzkD14tsMqOPNuiKlMvRHyeKb_ZpmBdSdvI5w4-jCedPs","secret":"ENNpAW2FQAnVHvGd3VX9oN2rM-nL8BZ9zsGnSQhx2kmkTl77ZqIOHOcrIu56lJcVfN35Qae07sfF4p4b","production":false,"paymentMethodId":"paypal","enabled":true}';
    var jsonDecoded = convert.jsonDecode(json);
    PayPalConfig payPalConfig = PayPalConfig.fromJson(jsonDecoded);

    try {
      var client =
          BasicAuthClient(payPalConfig.clientId!, payPalConfig.secret!);
      var response = await client.post(
          Uri.parse('$domain/v1/oauth2/token?grant_type=client_credentials'));
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['access_token'];
      } else {
        throw body['error_description'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future getAccessTokens() async {
    const String clientId =
        "AQK7mxS-t6zwvLbEIwcCePOUObK4yt_UiZYwzkD14tsMqOPNuiKlMvRHyeKb_ZpmBdSdvI5w4-jCedPs";
    const String secret =
        "ENNpAW2FQAnVHvGd3VX9oN2rM-nL8BZ9zsGnSQhx2kmkTl77ZqIOHOcrIu56lJcVfN35Qae07sfF4p4b";
    // const String baseUrl = "https://api.paypal.com";

    final String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$clientId:$secret'));

    var headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": basicAuth,
    };

    final Map<String, String> requestData = {
      "grant_type": "client_credentials",
    };

    await APIService().callAPI(
      params: {},
      headers: headers,
      // formDatas: dio.FormData.fromMap(requestData),
      serviceUrl: "$domain/v1/oauth2/token?grant_type=client_credentials",
      method: APIService.postMethod,
      success: (dio.Response response) async {
        print("Access token received successfully");
        accessToken = response.data["access_token"];
        print("Access Token: $accessToken");
      },
      error: (dio.Response response) {
        print("Error getting access token: ${response.statusCode}");
        print(response.data);
      },
      showProcess: true,
    );
  }

  Future addProduct() async {
    if (accessToken == null || accessToken?.isEmpty == true) {
      await getAccessTokens();
    }
    const String productName = "Monthly Subscription";
    const String productDescription =
        "Monthly Subscription For Donating us, My Christian Social Network";
    const String productCategory = "DONATION";
    const String productType = "DONATION";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
    final Map<String, dynamic> requestData = {
      // "id": "DonationProductID",
      "name": productName,
      "description": productDescription,
      "category": "SOFTWARE",
      "type": "SERVICE",
    };

    await APIService().callAPI(
      params: {},
      headers: headers,
      formDataMap: jsonEncode(requestData),
      serviceUrl: "$domain/v1/catalogs/products",
      method: APIService.postMethod,
      success: (dio.Response response) async {
        print("Product created successfully");
        final String productId = response.data["id"];
        print("Product ID: $productId");
      },
      error: (dio.Response response) {
        print("Error adding product: ${response.statusCode}");
        print(response.data);
      },
      showProcess: true,
    );
  }

  Future createPlan() async {
    await getAccessTokens();
    const String productName = "Monthly subscription";
    const String description = "Monthly subscription for donation.";
    const String currencyCode = "USD";
    const double price = 10.00;

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };

    final Map<String, dynamic> requestData = {
      "product_id": "PROD-1CT071845U278853T",
      "name": "Monthly Subscription",
      "description":
          "Monthly Subscription For Donating us, My Christian Social Network",
      "billing_cycles": [
        {
          "frequency": {"interval_unit": "MONTH", "interval_count": 1},
          "tenure_type": "REGULAR",
          "sequence": 1,
          "total_cycles": 12,
          "pricing_scheme": {
            "fixed_price": {
              "value": price.toString(),
              "currency_code": currencyCode
            }
          }
        }
      ],
      "payment_preferences": {"auto_bill_outstanding": true},
      "taxes": {"percentage": "0", "inclusive": false}
    };

    // final response = await dio.post("/v1/billing/plans", data: requestData);

    await APIService().callAPI(
      params: {},
      headers: headers,
      formDataMap: jsonEncode(requestData),
      serviceUrl: "$domain/v1/billing/plans",
      method: APIService.postMethod,
      success: (dio.Response response) async {
        print("Plan created successfully");
        final String planId = response.data["id"];
        print("Plan ID: $planId");
      },
      error: (dio.Response response) {
        print("Error creating plan: ${response.statusCode}");
        print(response.data);
      },
      showProcess: true,
    );
  }

  Future<Map<String, String>> createPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse('$domain/v1/payments/payment'),
          body: convert.jsonEncode(transactions),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body['links'] != null && body['links'].length > 0) {
          List links = body['links'];

          var executeUrl = '';
          var approvalUrl = '';
          final item = links.firstWhere((o) => o['rel'] == 'approval_url',
              orElse: () => null);
          if (item != null) {
            approvalUrl = item['href'];
          }
          final item1 = links.firstWhere((o) => o['rel'] == 'execute',
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1['href'];
          }
          return {'executeUrl': executeUrl, 'approvalUrl': approvalUrl};
        }
        //return null;
        throw Exception(body['message']);
      } else {
        if (body['details'] is List && body['details'].length > 0) {
          final details = body['details'][0];
          if (details is Map) {
            throw Exception(details['issue']);
          }
        }
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>> createRecurringPaypalPayment(
      transactions, accessToken) async {
    try {
      var response = await http.post(Uri.parse('$domain/v1/payments/payment'),
          body: convert.jsonEncode(transactions),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (body['links'] != null && body['links'].length > 0) {
          List links = body['links'];

          var executeUrl = '';
          var approvalUrl = '';
          final item = links.firstWhere((o) => o['rel'] == 'approval_url',
              orElse: () => null);
          if (item != null) {
            approvalUrl = item['href'];
          }
          final item1 = links.firstWhere((o) => o['rel'] == 'execute',
              orElse: () => null);
          if (item1 != null) {
            executeUrl = item1['href'];
          }
          return {'executeUrl': executeUrl, 'approvalUrl': approvalUrl};
        }
        //return null;
        throw Exception(body['message']);
      } else {
        if (body['details'] is List && body['details'].length > 0) {
          final details = body['details'][0];
          if (details is Map) {
            throw Exception(details['issue']);
          }
        }
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> executePayment(url, payerId, accessToken) async {
    try {
      var response = await http.post(url,
          body: convert.jsonEncode({'payer_id': payerId}),
          headers: {
            'content-type': 'application/json',
            'Authorization': 'Bearer ' + accessToken
          });

      final body = convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['id'];
      }
      return '';
    } catch (e) {
      rethrow;
    }
  }
}
