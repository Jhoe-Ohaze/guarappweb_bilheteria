import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarTab extends StatefulWidget
{
  @override
  _CalendarTabState createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab>
{
  CalendarController _calendarController;
  DateTime selectedDate, startDay, currentDate;

  @override
  void initState()
  {
    currentDate = DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    _calendarController = CalendarController();
    startDay = currentDate.isAfter(DateTime(2020,07,11)) ? currentDate.hour < 13 ?
        currentDate : currentDate.add(Duration(days: 1)): DateTime(2020, 07, 11);
    selectedDate = startDay;
    super.initState();
  }

  Future<int> getLimit() async
  {
    String day = selectedDate.day < 10 ? "0${selectedDate.day}":selectedDate.day.toString();
    String month = selectedDate.month < 10 ? "0${selectedDate.month}":selectedDate.month.toString();
    String year = selectedDate.year.toString();

    DocumentSnapshot snap =  await Firestore.instance
        .collection("limits").document("years").collection(year)
        .document("months").collection(month).document(day).get();

    try
    {
      if(snap.exists) return snap.data['expected'];
      else return 0;
    }
    catch(e){print(e);}
  }

  Widget calendar()
  {
    void _onDaySelected(DateTime day, List events)
    {
      setState(() => selectedDate = day);
    }

    return Container
      (
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration
          (
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 2),
            color: Colors.white
        ),
        child: SingleChildScrollView
          (
          child: TableCalendar
            (
            availableGestures: AvailableGestures.horizontalSwipe,
            locale: 'pt_BR',
            calendarController: _calendarController,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            startDay: startDay,
            endDay: DateTime(2020, 12, 31),
            initialSelectedDay: startDay,
            calendarStyle: CalendarStyle
              (
              selectedColor: Colors.blue[400],
              markersColor: Colors.red[700],
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle
              (
              centerHeaderTitle: true,
              titleTextStyle: TextStyle(fontSize: 20, fontFamily: 'Fredoka'),
              formatButtonVisible: false,
            ),
            onDaySelected: _onDaySelected,
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context)
  {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container
    (
      alignment: Alignment.topCenter,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      height: height,
      width: width,
      child: SingleChildScrollView
      (
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            Container
            (
              width: width > 400 ? 400 : width,
              height: width > 400 ? 400 : width,
              child: calendar(),
            ),
            SizedBox(height: 10),
            Container
              (
              height: 40,
              width: width > 400 ? 400 : width,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              decoration: BoxDecoration
                (
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 2),
                  color: Colors.white
              ),
              child: Row
                (
                children:
                [
                  Text("Quantidade esperada de pessoas:"),
                  Expanded(child: Container()),
                  FutureBuilder
                    (
                    future: getLimit(),
                    builder: (context, snapshot)
                    {
                      switch(snapshot.connectionState)
                      {
                        case ConnectionState.done:
                          {
                            return Text(snapshot.data.toString());
                          }
                        default:
                          return CircularProgressIndicator();
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
