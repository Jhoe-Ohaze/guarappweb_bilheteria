import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatefulWidget
{
  final FirebaseUser user;
  final String productid, year, month, day;

  ProductScreen(this.user, this.productid, this.year, this.month, this.day);
  @override
  _ProductScreenState createState() => _ProductScreenState(user, productid, year, month, day);
}

class _ProductScreenState extends State<ProductScreen>
{
  final String productid, year, month, day;
  FirebaseUser user;
  ValueNotifier<bool> canConfirm = ValueNotifier<bool>(false);
  _ProductScreenState(this.user, this.productid, this.year, this.month, this.day);
  ScrollController scrollController = ScrollController();
  GlobalKey<ScaffoldState> _scaffoldController = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context)
  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void confirm() async
    {
      canConfirm.value = false;
      user = await FirebaseAuth.instance.currentUser();
      await Firestore.instance
          .collection('payments')
          .document('years')
          .collection(year)
          .document('months')
          .collection(month)
          .document('days')
          .collection(day)
          .document(productid)
          .updateData({
        'confirmed_status': '${user.email}, ${DateTime.now()}'
      }).then((value) {
        _scaffoldController.currentState.hideCurrentSnackBar();
        _scaffoldController.currentState
            .showSnackBar(SnackBar(content: Text('Confirmado com sucesso')));
      }).catchError((e) {
        print(user.email);
        print(e);
        _scaffoldController.currentState.hideCurrentSnackBar();
        _scaffoldController.currentState.showSnackBar(
            SnackBar(content: Text('Não foi possível confirmar')));
      });
      setState(() {});
    }

    Future<QuerySnapshot> getPayment() async {
      QuerySnapshot snapshot = await Firestore.instance
          .collection('payments')
          .document('years')
          .collection(year)
          .document('months')
          .collection(month)
          .document('days')
          .collection(day)
          .where('order_number', isEqualTo: productid)
          .getDocuments();
      if (snapshot.documents.isNotEmpty) canConfirm.value = true;
      if (snapshot.documents.isEmpty){;}
      else if (snapshot.documents
          .elementAt(0)
          .data['confirmed_status'] != '') canConfirm.value = false;
      return snapshot;
    }

    Widget infoField()
    {
      return FutureBuilder
        (
        future: getPayment(),
        builder: (context, snapshot)
        {
          QuerySnapshot querySnapshot = snapshot.data;
          switch (snapshot.connectionState)
          {
            case ConnectionState.done:
              if (querySnapshot.documents.isEmpty)
              {
                return Container
                  (
                  alignment: Alignment.center,
                  height: height - 320,
                  width: width - 60,
                  child: Column
                    (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    [
                      Icon(Icons.error, size: 50),
                      SizedBox(height: 10),
                      Text
                        (
                        'Produto não encontrado',
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                );
              }
              else
              {
                Map rndmap = querySnapshot.documents.elementAt(0).data;

                Map map;
                if (rndmap['confirmed_status'] != '')
                {
                  map =
                  {
                    'confirmed_status': rndmap['confirmed_status'],
                    'customer_name': rndmap['customer_name'],
                    'product_adult_amount': rndmap['product_adult_amount'],
                    'product_kid_amount': rndmap['product_kid_amount'],
                    'created_date': rndmap['created_date'],
                    'customer_identity': rndmap['customer_identity'],
                    'customer_email': rndmap['customer_email'],
                    'customer_phone': rndmap['customer_phone'],
                  };
                }
                else
                {
                  map =
                  {
                    'customer_name': rndmap['customer_name'],
                    'product_adult_amount': rndmap['product_adult_amount'],
                    'product_kid_amount': rndmap['product_kid_amount'],
                    'created_date': rndmap['created_date'],
                    'customer_identity': rndmap['customer_identity'],
                    'customer_email': rndmap['customer_email'],
                    'customer_phone': rndmap['customer_phone'],
                  };
                }
                List list = map.keys.toList();

                return Container
                  (
                    height: height - 320,
                    child: Scrollbar
                      (
                        isAlwaysShown: true,
                        controller: scrollController,
                        child: ListView.builder
                          (
                          controller: scrollController,
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index)
                          {
                            String key = map.keys.elementAt(index);
                            String tkey;
                            switch (key)
                            {
                              case 'created_date':
                                tkey = 'Data de realização do pedido';
                                break;
                              case 'customer_email':
                                tkey = 'E-mail do Cliente';
                                break;
                              case 'customer_identity':
                                tkey = 'CPF do Cliente';
                                break;
                              case 'customer_name':
                                tkey = 'Nome do Cliente';
                                break;
                              case 'customer_phone':
                                tkey = 'Telefone do Cliente';
                                break;
                              case 'product_adult_amount':
                                tkey = 'Quantidade de Adultos';
                                break;
                              case 'product_kid_amount':
                                tkey = 'Quantidade de Crianças';
                                break;
                              case 'confirmed_status':
                                tkey = 'Confirmado por';
                                break;
                            }

                            String value;
                            map.values.elementAt(index).toString();

                            if (key == 'payment_maskedcreditcard')
                              value = '************' +
                                  map.values.elementAt(index).substring(12, 16);
                            else if (key == 'price')
                            {
                              String price = map.values.elementAt(index).toString();
                              value = 'R\$${price.substring(0, 2)}'
                                  ',${price.substring(2, 4)}';
                            }
                            else
                              value = map.values.elementAt(index).toString();

                            return ListTile
                              (
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
              return Container
                (
                height: height - 320,
                width: width - 60,
                child: Center(child: CircularProgressIndicator()),
              );
          }
        },
      );
    }

    Widget confirmButton()
    {
      return ValueListenableBuilder
        (
        valueListenable: canConfirm,
        builder: (context, value, child)
        {
          return FlatButton
            (
            disabledColor: Colors.blueGrey[100],
            color: Colors.blue,
            onPressed: value ? () => confirm() : null,
            child: Container
              (
                alignment: Alignment.center,
                height: 60,
                child: Text("Confirmar entrada",
                    style: TextStyle(color: Colors.white))
            ),
          );
        },
      );
    }

    return Scaffold
    (
      key: _scaffoldController,
      appBar: AppBar(title: Text('Confirmar Entrada')),
      body: Container
      (
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
          [
            infoField(),
            Divider(thickness: 2),
            confirmButton()
          ],
        ),
      )
    );
  }
}
