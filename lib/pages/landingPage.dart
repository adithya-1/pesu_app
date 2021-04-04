import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:pesu_app/pages/attendance.dart';
import 'package:pesu_app/pages/feedback.dart';
import 'package:pesu_app/pages/notifications.dart';
import 'package:pesu_app/services/auth.dart';

class LandingPage extends StatefulWidget {
  LandingPage({Key key, this.userId, this.auth, this.onSignedOut})
      : super(key: key);
  final BaseAuth auth;

  final VoidCallback onSignedOut;
  final String userId;
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;

  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFf96327),
          title: Text("PESU"),
        ),
        drawer: Theme(
          data: Theme.of(context).copyWith(
            backgroundColor: const Color(0xFFf96327),
          ),
          child: Drawer(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Log Out'),
                  onTap: widget.onSignedOut,
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavyBar(
          selectedIndex: _selectedIndex,
          showElevation: true, // use this to remove appBar's elevation
          onItemSelected: (index) => setState(() {
            _selectedIndex = index;
          }),
          backgroundColor: Colors.white,

          items: [
            BottomNavyBarItem(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.redAccent[700],
              ),
              title: Text(
                'Attendance',
                style: TextStyle(color: null),
              ),
              activeColor: Colors.redAccent[700],
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(
                Icons.notifications,
              ),
              title: Text(
                'Notifications',
                style: TextStyle(color: null),
              ),
              activeColor: Color(0xFF3599EF),
              textAlign: TextAlign.center,
            ),
            BottomNavyBarItem(
              icon: Icon(Icons.feedback),
              title: Text(
                'Feedback',
                style: TextStyle(color: null),
              ),
              activeColor: Color(0xFFFF3A90),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ));
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          Attendance(
            userId: widget.userId,
          ),
          Notifications(),
          FeedBack(
            userId: widget.userId,
          )
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        },
      ),
    );
  }
}
