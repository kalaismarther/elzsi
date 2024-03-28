import 'dart:convert';
import 'package:elzsi/Api/urls.dart';
import 'package:elzsi/Utils/common.dart';
import 'package:http/http.dart' as http;

class Api {
  //LOGIN SCREEN
  Future login(data) async {
    String url = liveURL + loginUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Something went wrong');
    }
  }

  //VERIFY OTP SCREEN
  Future verifyOtp(data) async {
    String url = liveURL + verifyOtpUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future resendOtp(data) async {
    String url = liveURL + resendOtpUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: json.encode(data));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Something went wrong');
    }
  }

  //HOME SCREEN
  Future homeContent(data, token, context) async {
    String url = liveURL + homeContentUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future notify(data, token, context) async {
    String url = liveURL + notificationUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      print(json.decode(response.body));
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //NOTIFICATION SCREEN
  Future getNotifications(data, token, context) async {
    String url = liveURL + getNotificationsUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //SELECT SELLER SCREEN
  Future getSellers(data, token, context) async {
    String url = liveURL + getSellerUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future requestSeller(data, token, context) async {
    String url = liveURL + requestSellerUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future getRequest(data, token, context) async {
    String url = liveURL + getRequestUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //MY SELLER SCREEN
  Future getLinkedSellers(data, token, context) async {
    String url = liveURL + linkedSellersUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //PROPERTIES SCREEN
  Future getLinkedProjects(data, token, context) async {
    String url = liveURL + linkedProjectsUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //VIEW DETAILS SCREEN
  Future getLinkedSellerProjects(data, token, context) async {
    String url = liveURL + linkedSellerProjectsUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //VIEW PROPERTY DETAIL SCREEN
  Future getLinkedProjectDetails(data, token, context) async {
    String url = liveURL + linkedProjectDetailsUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //MY PROFILE SCREEN
  Future getAgentProfile(data, token, context) async {
    String url = liveURL + getAgentProfileUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future getPincodes(data, token, context) async {
    String url = liveURL + getPincodesUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future getAreas(data, token, context) async {
    String url = liveURL + getAreasUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future deleteProfileImage(data, token, context) async {
    String url = liveURL + deleteProfileImageUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  Future projectUnitEntry(data, token, context) async {
    String url = liveURL + projectUnitEntryUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //LEADER : EXECUTIVE SCREEN
  Future getExecutivesList(data, token, context) async {
    String url = liveURL + executivesListUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }

  //LOGOUT
  Future logout(data, token, context) async {
    String url = liveURL + logoutUrl;

    final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'x-api-key': token},
        body: json.encode(data));

    if (response.statusCode == 200) {
      if (json.decode(response.body)['status'].toString() == '3') {
        Common().showToast('Session Expired');
        Common().logout(context);
      } else {
        return json.decode(response.body);
      }
    } else {
      throw Exception('Something went wrong');
    }
  }
}
