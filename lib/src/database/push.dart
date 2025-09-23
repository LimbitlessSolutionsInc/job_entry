import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../styles/globals.dart';

class Messaging{
  static Future<void> sendEmailAttachment(String toEmails, String ccEmails, String subject, String body, List<dynamic> attachments) async{
    try{
      String payload = jsonEncode({
        'to': toEmails,
        'cc': ccEmails,
        'subject': subject,
        'body': body,
        'attachments': attachments,
        'pos': 0,
      });
      print('payload: $payload');

      String url = 'https://us-central1-limbitless-solutions.cloudfunctions.net/sendUsersEmailAttachment';

      await http.post(
        Uri.parse(url), 
        body: payload
      ).then((value){
        print(value.body);
      });
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
  
  static Future<void> sendPushMessage(List<String> names,String title, String body,[bool toTeam = true]) async {
    if (names.isEmpty) {
      print('Unable to send FCM message, no token exists.');
    }
    else{
      try{
        String payload = jsonEncode({
          'uid': currentUser.uid,
          'uids': names,
          'title': title,
          'message': body,
        });

        String url = toTeam?
          'https://us-central1-limbitless-solutions.cloudfunctions.net/userChat?secret=RidrAZIh7jYOVHllkfYs8wVoykk2'
          :'https://us-central1-limbitless-solutions.cloudfunctions.net/userChat?secret=qhc4YxJd9jZD4fSKKsIPQyFwigb2';

        await http.post(
          Uri.parse(url), 
          body: payload
        ).then((value){
          print(value.body);
        });
        print('FCM request for device sent!');
      } catch (e) {
        print(e);
      }
    }
  }
  static Future<void> sendChatMessage(String url, String title, String body) async {
    try{
      String payload = jsonEncode({
        'text': '*$title* $body',
      });

      await http.post(
        Uri.parse(url), 
        body: payload
      ).then((value){
        print(value.body);
      });
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
}