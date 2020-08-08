import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guarappwebbilheteria/tabs/calendar_tab.dart';
import 'package:guarappwebbilheteria/tabs/ticket_tab.dart';
import 'package:guarappwebbilheteria/tabs/search_tab.dart';

class InfoScreen extends StatefulWidget {
  final FirebaseUser user;
  InfoScreen(this.user);

  @override
  _InfoScreenState createState() => _InfoScreenState(user);
}

class _InfoScreenState extends State<InfoScreen> {
  int _currentIndex = 0;
  final FirebaseUser user;
  _InfoScreenState(this.user);

  void _onItemTapped(index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> widgetList;

  @override
  void initState() {
    super.initState();
    widgetList = [TicketTab(user), SearchTab(user), CalendarTab()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Bilheteria')),
      body: widgetList.elementAt(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          unselectedFontSize: 10,
          selectedFontSize: 10,
          iconSize: 30,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              title: Text('Verificar Bilhete'),
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), title: Text('Procurar Bilhete')),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              title: Text('Ver Limites'),
            )
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped),
    );
  }
}
