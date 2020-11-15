import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:getwidget/getwidget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:projeto_muh_compmov/drawer/Drawer.dart';
import 'package:projeto_muh_compmov/models/user_model.dart';
import 'package:projeto_muh_compmov/screens/login_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class HelpScreen extends StatelessWidget {
  List _nome = new List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: new IconThemeData(color: Colors.black),
        title: Image.asset(
          "assets/vakinha.png",
          alignment: Alignment.center,
          scale: 3.5,
        ),
        actions: [
          RaisedButton(
            // color: Colors.white,
            //padding: EdgeInsets.only(0.2),
            child: Icon(Icons.message),
            color: Colors.white,
            onPressed: () {
              // vai para as mensagens...
            },
          ),
        ],
      ),
      body: CustomForm(_nome),
      drawer: CustomDrawer(this._nome),
    );
  }
}

class CustomForm extends StatefulWidget {
  List _nome;

  CustomForm(List nome) {
    this._nome = nome;
  }
  @override
  _CustomFormState createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  popupReportedProblem(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "Problema reportado com sucesso!"),
            content: Text(
                "Obrigado, iremos analisar e tentar consertar isso o mais rapido possivel."),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  popupNaoEstaLogado(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
                "ERRO"),
            content: Text(
                "Faça o login para reportar o problema"),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                child: Text('ok'),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen())
                  );
                },
              )
            ],
          );
        });
  }

  final TextEditingController _descriptionProblemController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      if (model.isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        this.widget._nome.addAll(model.nome);
        return Form(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(left: 10, right: 10, top: 30),
                child: Column(children: <Widget>[
                  GFTypography(
                    text: 'Perguntas frequentes',
                  ),
                  GFAccordion(
                    title: 'Como faço para criar um novo produto na minha fazenda?',
                    content: 'Selecione o menu no canto esquerdo superior da tela e vá em "Minha fazenda". Selecione a fazenda a qual você deseja adicionar um item e vá em "adicionar novo produto"',
                    collapsedIcon: Icon(Icons.add),
                    expandedIcon: Icon(Icons.minimize),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  GFAccordion(
                    title: 'Como faço para acessar as minhas fazendas',
                    content:
                        'Selecione o menu no canto esquerdo superior da tela e vá em "minha fazenda". Lá terá um campo escrito "Selecione uma fazenda" que conterá todas as fazendas que você registrou',
                    collapsedIcon: Icon(Icons.add),
                    expandedIcon: Icon(Icons.minimize),
                    contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RaisedButton(
                      color: Colors.black,
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Relatar um problema'),
                                content: Stack(
                                  overflow: Overflow.visible,
                                  children: <Widget>[
                                    Positioned(
                                      right: -40.0,
                                      top: -40.0,
                                      child: InkResponse(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: CircleAvatar(
                                          child: Icon(Icons.close),
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller:
                                                  _descriptionProblemController,
                                              validator: (field) {
                                                if (field.length == 0)
                                                  return "Nos informe o problema!";
                                                return null;
                                              },
                                              keyboardType:
                                                  TextInputType.multiline,
                                              minLines: 6,
                                              maxLines: 6,
                                              decoration: InputDecoration(
                                                  labelText:
                                                      "Descreva o problema",
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  // fillColor: Color(0xFFF4F5F6),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.elliptical(
                                                                10, 10)),
                                                    borderSide: BorderSide(),
                                                  ),
                                                  hintText: ''),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: RaisedButton(
                                              onPressed: () {
                                                if(model.isLoggedIn()){
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    Map<String,dynamic> description = {
                                                      'description': _descriptionProblemController.text
                                                    };
                                                    model.reportProblem(description);
                                                    Navigator.of(context).pop();
                                                    popupReportedProblem(context);
                                                  }
                                                }
                                                else{
                                                    popupNaoEstaLogado(context);
                                                }
                                              },
                                              child: Text("Enviar"),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      child: Text('Relatar um problema',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ])));
      }
    });
  }
}
