import 'package:agenda_app/helper/contact_helper.dart';
import 'package:agenda_app/ui/contact.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    this._getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Agenda Flutter"),
          backgroundColor: Colors.red,
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                    child: Text("Ordernar de A-Z"),
                    value: OrderOptions.orderaz),
                const PopupMenuItem<OrderOptions>(
                    child: Text("Ordernar de Z-A"), value: OrderOptions.orderza)
              ],
              onSelected: this._orderList,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            this._showContactPage();
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.red,
        ),
        body: ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return _contactCard(context, index);
            }));
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }

    setState(() {});
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null
                            ? FileImage(File(contacts[index].img))
                            : AssetImage("images/person.png"),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        )),
                    Text(contacts[index].phone ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        this._showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: FlatButton(
                                onPressed: () {
                                  launch("tel:${contacts[index].phone}");
                                  Navigator.pop(context);
                                },
                                child: Text("Ligar",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 20.0)))),
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  this._showContactPage(
                                      contact: contacts[index]);
                                },
                                child: Text("Editar",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 20.0)))),
                        Padding(
                            padding: EdgeInsets.all(10.0),
                            child: FlatButton(
                                onPressed: () {
                                  this
                                      .contactHelper
                                      .deleteContact(contacts[index].id);
                                  setState(() {
                                    contacts.removeAt(index);
                                    Navigator.pop(context);
                                  });
                                },
                                child: Text("Excluir",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 20.0))))
                      ],
                    ));
              });
        });
  }

  void _getAllContacts() {
    contactHelper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showContactPage({Contact contact}) async {
    final returnedContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));

    if (returnedContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(returnedContact);
      } else {
        await this.contactHelper.saveContact(returnedContact);
      }
      this._getAllContacts();
    }
  }
}
