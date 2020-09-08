import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:guarappwebbilheteria/screens/product_screen.dart';

class SearchTab extends StatefulWidget
{
  final FirebaseUser user;
  SearchTab(this.user);

  @override
  _SearchTabState createState() => _SearchTabState(user);
}

class _SearchTabState extends State<SearchTab>
{
  final FirebaseUser user;
  _SearchTabState(this.user);

  String cpf = '';
  String year = '2020', month = '09', day = '10';

  bool firstRun = true;
  bool confirmed = false;

  TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  void checkCustomer()
  {
    cpf = _controller.text;
    setState((){});
  }

  void loadConfirmed()
  {
    cpf = '';
    confirmed = true;
    setState((){});
  }

  void loadUnconfirmed()
  {
    cpf = '';
    confirmed = false;
    setState((){});
  }

  void openProduct(productid)
  {
    Navigator.push(context, new MaterialPageRoute(builder: (context) =>
        ProductScreen(this.user, productid, year, month, day)));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    Future<QuerySnapshot> getPayments() async
    {
      QuerySnapshot snapshot;
      if(cpf != '')
        {
          snapshot = await Firestore.instance
              .collection('payments')
              .document('years')
              .collection(year)
              .document('months')
              .collection(month)
              .document('days')
              .collection(day)
              .where('customer_identity', isEqualTo: cpf)
              .getDocuments();
        }
      else
      {
        if(!confirmed)
          snapshot = await Firestore.instance
            .collection('payments')
            .document('years')
            .collection(year)
            .document('months')
            .collection(month)
            .document('days')
            .collection(day)
            .where('confirmed_status', isLessThanOrEqualTo: '')
            .getDocuments();
        else
          snapshot = await Firestore.instance
              .collection('payments')
              .document('years')
              .collection(year)
              .document('months')
              .collection(month)
              .document('days')
              .collection(day)
              .where('confirmed_status', isGreaterThan: '')
              .getDocuments();
      }
      return snapshot;
    }

    Widget fieldAndButton() {
      return Row(
        children: [
          Container(
            width: width - 155,
            padding: EdgeInsets.only(right: 5),
            child: TextField(
              decoration: InputDecoration
                (
                labelText: "CPF",
                hintText: "CPF do cliente",
                border: OutlineInputBorder(),
              ),
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))
              ],
              controller: _controller,
            ),
          ),
          FlatButton(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
                height: 60,
                alignment: Alignment.center,
                child:
                Text("Pesquisar", style: TextStyle(color: Colors.white))),
            onPressed: checkCustomer,
            color: Colors.blue,
          )
        ],
      );
    }

    Widget allButton()
    {
      return Row
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
          FlatButton(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
                height: 55,
                width: width/2 - 67,
                alignment: Alignment.center,
                child:
                Text("Confirmados", style: TextStyle(color: Colors.white))),
            onPressed: loadConfirmed,
            color: Colors.lightGreen,
          ),
          SizedBox(width: 10),
          FlatButton(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
                height: 55,
                width: width/2 - 67,
                alignment: Alignment.center,
                child:
                Text("Não Confirmados", style: TextStyle(color: Colors.white))),
            onPressed: loadUnconfirmed,
            color: Colors.redAccent,
          ),
        ],
      );
    }

    Widget infoField() {
      return FutureBuilder(
        future: getPayments(),
        builder: (context, snapshot) {
          QuerySnapshot querySnapshot = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (firstRun) {
                firstRun = false;
                return Container(
                  alignment: Alignment.center,
                  height: height - 395,
                  width: width - 60,
                );
              }
              if (querySnapshot.documents.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  height: height - 395,
                  width: width - 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 50),
                      SizedBox(height: 10),
                      Text(
                        'Cliente Não Encontrado',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              } else {
                List<DocumentSnapshot> mapList = querySnapshot.documents;
                mapList.sort((a, b) => a.data['customer_name'].compareTo(b.data['customer_name']));
                
                return Container
                (
                  height: height - 395,
                  child: Scrollbar
                  (
                    isAlwaysShown: true,
                    controller: scrollController,
                    child: ListView.builder
                    (
                      controller: scrollController,
                      shrinkWrap: true,
                      itemCount: mapList.length,
                      itemBuilder: (context, index)
                      {
                        String tkey = mapList.elementAt(index).data['customer_name'];
                        String value = '${mapList.elementAt(index).data['product_adult_amount']}'
                            ' - ${mapList.elementAt(index).data['created_date']}';
                        return ListTile
                        (
                          onTap: () => openProduct(mapList.elementAt(index).data['order_number']),
                          title: Text(tkey),
                          subtitle: Text(value),
                        );
                      },
                    )
                  )
                );
              }
              break;
            default:
              return Container(
                height: height - 395,
                width: width - 60,
                child: Center(child: CircularProgressIndicator()),
              );
          }
        },
      );
    }

    return Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            fieldAndButton(),
            Divider(),
            allButton(),
            Divider(thickness: 2),
            infoField(),
          ],
        ),
    );
  }
}
