import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pesu_app/pages/splash.dart';

class Attendance extends StatefulWidget {
  Attendance({
    Key key,
    this.userId,
  }) : super(key: key);
  final String userId;

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  int teacherPage = 1;
  List teacherChooseClass = [];
  int teacherRadioChooseClass = -1;
  String teacherSelectedClass = '';
  List teacherStudentList = [];
  List newAttendance = [];
  Map<String, dynamic> currentStudentAttendance = Map();

  Widget submitButton(function, text) {
    return GestureDetector(
      onTap: function,
      child: // Rectangle
          Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: text == 'Continue' ? 100 : 70,
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xffd0d0d0),
                          offset: Offset(1, 2),
                          blurRadius: 5,
                          spreadRadius: 0),
                      BoxShadow(
                          color: const Color(0xffffffff),
                          offset: Offset(-1, -2),
                          blurRadius: 5,
                          spreadRadius: 0)
                    ],
                    color: Colors.orange),
                child: Center(
                    child: // I’ll do it later
                        Text(text,
                            textScaleFactor: 1.0,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontFamily: "Nunito",
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 20),
                            textAlign: TextAlign.center))),
          ],
        ),
      ),
    );
  }

  Future<bool> subFunctionOne() async {
    DocumentReference _ref = Firestore.instance
        .collection('Attendance')
        .document(widget.userId)
        .collection('Class')
        .document(teacherSelectedClass);

    Map studentID = Map();
    await _ref.get().then((value) {
      setState(() {
        studentID = value.data;
      });
    });

    studentID.forEach((key, value) async {
      DocumentReference _ref1 =
          Firestore.instance.collection('Users').document(key);
      await _ref1.get().then((value1) {
        teacherStudentList.add([key, value1.data['name']]);
        newAttendance.add([key, false]);
      });

      currentStudentAttendance[key] = value;
    });
    return Future.value(true);
  }

  void functionteacherPageOne() async {
    await subFunctionOne();
    sleep(const Duration(seconds: 3));
    setState(() {
      teacherPage = 2;
    });
  }

  void functionteacherPageTwo() {
    setState(() {
      for (int i = 0; i < newAttendance.length; i++) {
        if (newAttendance[i][1]) {
          currentStudentAttendance[newAttendance[i][0]] += '1';
        } else {
          currentStudentAttendance[newAttendance[i][0]] += '0';
        }
      }

      teacherPage = 3;
    });
  }

  void functionteacherPageThree() {
    DocumentReference _ref2 = Firestore.instance
        .collection('Attendance')
        .document(widget.userId)
        .collection('Class')
        .document(teacherSelectedClass);

    _ref2.updateData(currentStudentAttendance);
    setState(() {
      teacherPage = 1;
      teacherChooseClass = [];
      teacherRadioChooseClass = -1;
      teacherSelectedClass = '';
      teacherStudentList = [];
      newAttendance = [];
      currentStudentAttendance = Map();
    });
  }

  Widget teacherAttendance() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return StreamBuilder(
          stream: Firestore.instance
              .collection('Attendance')
              .document(widget.userId)
              .collection('Class')
              .snapshots(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) return Splash();

            snapshot.data.documents.forEach((value) {
              if (!teacherChooseClass.contains(value.documentID))
                teacherChooseClass.add(value.documentID);
            });

            return Scaffold(
                body: teacherPage == 1
                    ? Column(children: [
                        Text('Choose Section'),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: teacherChooseClass.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                  leading: Radio(
                                    activeColor: Colors.orange,
                                    value: index,
                                    groupValue: teacherRadioChooseClass,
                                    onChanged: (value) {
                                      setState(() {
                                        teacherRadioChooseClass = value;
                                        teacherSelectedClass =
                                            teacherChooseClass[index];
                                      });
                                    },
                                  ),
                                  title: Text(teacherChooseClass[index]));
                            }),
                        submitButton(functionteacherPageOne, 'Submit')
                      ])
                    : teacherPage == 2
                        ? Column(children: [
                            Text('Choose Students'),
                            ListView.builder(
                                shrinkWrap: true,
                                itemCount: teacherStudentList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ListTile(
                                      leading: Checkbox(
                                        activeColor: Colors.orange,
                                        value: newAttendance[index][1],
                                        onChanged: (value) {
                                          setState(() {
                                            newAttendance[index][1] = value;
                                          });
                                        },
                                      ),
                                      title:
                                          Text(teacherStudentList[index][1]));
                                }),
                            submitButton(functionteacherPageTwo, 'Submit')
                          ])
                        : teacherPage == 3
                            ? Column(
                                children: [
                                  Text(
                                      'Attendance Updated,press continue to return to the original page'),
                                  submitButton(
                                      functionteacherPageThree, 'Continue')
                                ],
                              )
                            : Text('Attendance'));
          });
    });
  }

  Widget studentAttendance(userData) {
    List myAttendanceDetails = [];
    List classDetails = [];
    return StreamBuilder(
        stream: Firestore.instance.collectionGroup('Class').snapshots(),
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return new Splash();
          }
          snapshot.data.documents.forEach((element) {
            element.data.forEach((key, value) {
              if (key == widget.userId) {
                if (!classDetails.contains(element.data['class'])) {
                  classDetails.add(element.data['class']);
                  myAttendanceDetails.add(
                      ((('1'.allMatches(value).length) / (value.length)) * 100)
                          .toStringAsFixed(2)
                          .toString());
                }
              }
            });
          });
          return Scaffold(
            body: Column(children: [
              Text('Attendance'),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: myAttendanceDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(classDetails[index]),
                      trailing: Text(myAttendanceDetails[index]),
                    );
                  })
            ]),
          );
        });
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

          return isTeacher ? teacherAttendance() : studentAttendance(userData);
        });
  }
}
