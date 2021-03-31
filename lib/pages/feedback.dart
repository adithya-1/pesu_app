import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pesu_app/pages/splash.dart';

class FeedBack extends StatefulWidget {
  FeedBack({
    Key key,
    this.userId,
  }) : super(key: key);
  final String userId;
  @override
  _FeedBackState createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  Widget teacherFeedback() {
    return StreamBuilder(
        stream: Firestore.instance.collection('Feedback').snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) return Splash();
          List feedback = [];
          String subjectName = '';
          String teacherName = '';

          print(snapshot.data);
          snapshot.data.documents.forEach((element) {
            if (element.data[widget.userId] != null) {
              subjectName = element.data[widget.userId]['subject'];
              teacherName = element.data[widget.userId]['name'];
              print(element.data[widget.userId]);
              String temp = 'Was good at explaining';
              feedback.add([
                temp,
                element.data[widget.userId][temp].length != 0
                    ? (element.data[widget.userId][temp].fold(
                            0, (previous, current) => previous + current)) /
                        element.data[widget.userId][temp].length
                    : 0
              ]);
              temp = 'Taught at appropriate pace';
              feedback.add([
                temp,
                element.data[widget.userId][temp].length != 0
                    ? (element.data[widget.userId][temp].fold(
                            0, (previous, current) => previous + current)) /
                        element.data[widget.userId][temp].length
                    : 0
              ]);
              temp = 'Was able to complete syllabus within time';
              feedback.add([
                temp,
                element.data[widget.userId][temp].length != 0
                    ? (element.data[widget.userId][temp].fold(
                            0, (previous, current) => previous + current)) /
                        element.data[widget.userId][temp].length
                    : 0
              ]);
              temp = 'Was available to answer questions during office hours';
              feedback.add([
                temp,
                element.data[widget.userId][temp].length != 0
                    ? (element.data[widget.userId][temp].fold(
                            0, (previous, current) => previous + current)) /
                        element.data[widget.userId][temp].length
                    : 0
              ]);
              temp = 'Overall rating';
              feedback.add([
                temp,
                element.data[widget.userId][temp].length != 0
                    ? (element.data[widget.userId][temp].fold(
                            0, (previous, current) => previous + current)) /
                        element.data[widget.userId][temp].length
                    : 0
              ]);
              print(feedback);
            }
          });
          return Scaffold(
            body: Column(
              children: [
                Text(subjectName),
                Text(teacherName),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: feedback.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(feedback[index][0].toString()),
                        trailing: Text(feedback[index][1].toString()),
                      );
                    }),
              ],
            ),
          );
        });
  }

  Widget studentFeedback() {
    return Scaffold(
      body: Center(child: Text('Feedback')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('Users')
            .document(widget.userId)
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return new Splash();
          }
          var userData = snapshot.data;

          bool isTeacher = userData['isTeacher'];

          return isTeacher ? teacherFeedback() : studentFeedback();
        });

    //  Scaffold(
    //   backgroundColor: Colors.blue,
    //   body: Center(child: Text('Feedback')),
    // );
  }
}
