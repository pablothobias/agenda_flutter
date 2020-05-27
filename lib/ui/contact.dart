import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:agenda_app/helper/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameFocus = new FocusNode();

  final _nameController = new TextEditingController();
  final _phoneController = new TextEditingController();
  final _emailController = new TextEditingController();

  bool _userEdited = false;
  Contact _editContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact.toMap());
    }

    this._nameController.text = this._editContact.name;
    this._emailController.text = this._editContact.email;
    this._phoneController.text = this._editContact.phone;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (this._editContact.name != null &&
                  this._editContact.name.isNotEmpty) {
                Navigator.pop(context, this._editContact);
              } else {
                FocusScope.of(context).requestFocus(this._nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editContact.img != null
                                ? FileImage(File(_editContact.img))
                                : AssetImage("images/person.png"),
                            fit: BoxFit.cover)),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.gallery)
                        .then((file) {
                      print(file);
                      if (file == null) return;
                      setState(() {
                        this._editContact.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: this._nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    this._userEdited = true;
                    setState(() {
                      this._editContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "E-mail"),
                  onChanged: (text) {
                    this._userEdited = true;
                    this._editContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    this._userEdited = true;
                    this._editContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                )
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }

  Future<bool> _requestPop() {
    if (this._userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações"),
              content:
                  Text("Ao deixar a página suas alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text("Sim"))
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
