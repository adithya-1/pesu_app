import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pesu_app/pages/splash.dart';

class Notifications extends StatefulWidget {
  Notifications({Key key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('Notifications').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Splash();
          List notif = [];
          snapshot.data.documents.forEach((element) {
            if (element.data['notif'] != null) {
              notif.add(element.data['notif']);
            }
          });
          return notif.length == 0
              ? Scaffold(body: Center(child: Text('No new notifications')))
              : Scaffold(
                  body: new ListView.builder(
                      itemCount: notif.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(notif[index].toString()),
                        );
                      }));
        });

    // return Scaffold(
    //   backgroundColor: Colors.green,
    //   body: Center(child: Text('Notifications')),
    // );
  }
}
