import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:guarappwebbilheteria/screens/qr_screen.dart';

class TicketTab extends StatefulWidget
{
  final FirebaseUser user;
  TicketTab(this.user);

  @override
  _TicketTabState createState() => _TicketTabState(user);
}

class _TicketTabState extends State<TicketTab>
{
  final FirebaseUser user;
  _TicketTabState(this.user);

  String productID = '';
  String year, month, day;
  String text =
      'Produto não encontrado, verifique se o código digitado está correto.';

  bool firstRun = true;

  static const IconData qricon = IconData(0xe800, fontFamily: 'qricon', fontPackage: null);

  TextEditingController _controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  ValueNotifier<bool> canConfirm = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context)
  {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void checkProduct() {
      setState(() {
        canConfirm.value = false;
        productID = _controller.text;
        if (productID.isNotEmpty &&
            (productID.length > 20 && productID.length < 30)) {
          year = productID.substring(0, 4);
          month = productID.substring(4, 6);
          day = productID.substring(6, 8);
        }
      });
    }

    void confirm() async {
      await Firestore.instance
          .collection('payments')
          .document('years')
          .collection(year)
          .document('months')
          .collection(month)
          .document('days')
          .collection(day)
          .document(productID)
          .updateData({
        'confirmed_status': '${user.email}, ${DateTime.now()}'
      }).then((value) {
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text('Confirmado com sucesso')));
      }).catchError((e) {
        print(user.email);
        print(e);
        Scaffold.of(context).hideCurrentSnackBar();
        Scaffold.of(context).showSnackBar(
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
          .where('order_number', isEqualTo: productID)
          .getDocuments();
      if (snapshot.documents.isNotEmpty) canConfirm.value = true;
      if (snapshot.documents.isEmpty)
        ;
      else if (snapshot.documents
          .elementAt(0)
          .data
          .containsKey('confirmed_status')) canConfirm.value = false;
      return snapshot;
    }

    Widget fieldAndButton()
    {
      return Row
      (
        children:
        [
          Container
          (
            width: width - 160,
            padding: EdgeInsets.all(5),
            child: Row
            (
              children:
              [
                Container
                (
                  width: width - 240,
                  child: TextField
                  (
                    decoration: InputDecoration
                    (
                      labelText: "ID",
                      hintText: "Código do produto (ID)",
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: <TextInputFormatter>
                    [
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]"))
                    ],
                    controller: _controller,
                  ),
                ),
                IconButton
                (
                  icon: Icon(qricon),
                  iconSize: 50,
                  onPressed: () => Navigator.of(context).push
                    (MaterialPageRoute(builder: (context) => QrScreen(_controller))),
                )
              ],
            ),
          ),
          FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
                height: 55,
                alignment: Alignment.center,
                child:
                    Text("Pesquisar", style: TextStyle(color: Colors.white))),
            onPressed: checkProduct,
            color: Colors.blue,
          )
        ],
      );
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
              if(firstRun)
              {
                firstRun = false;
                return Container
                  (
                  alignment: Alignment.center,
                  height: height - 320,
                  width: width - 60,
                );
              }
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
                        text,
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
                if (rndmap['confirmed_status'] != null)
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

    return Container
    (
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Column
      (
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        [
          fieldAndButton(),
          Divider(thickness: 2),
          infoField(),
          Divider(thickness: 2),
          confirmButton()
        ],
      ),
    );
  }
}
