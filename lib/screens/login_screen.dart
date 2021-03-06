import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projeto_muh_compmov/models/user_model.dart';
import 'package:projeto_muh_compmov/screens/cadastro_fazenda_screen.dart';
import 'package:projeto_muh_compmov/screens/TelaPrincipalEntrada.dart';
import 'package:projeto_muh_compmov/screens/fazenda_selecionada_screen.dart';
import 'package:projeto_muh_compmov/screens/feed_screen.dart';
//import 'package:projeto_muh_compmov/screens/grid_visitante.dart';
import 'package:projeto_muh_compmov/screens/item_registration_screen.dart';
import 'package:projeto_muh_compmov/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

import 'grid_visitante.dart';
class LoginScreen extends StatefulWidget {
@override
_LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List name;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          body:ScopedModelDescendant<UserModel>(
            builder: (context,child,model){
              if(model.isLoading){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }else{

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.all(6.0),
                    children: [
                      Container(
                        alignment: Alignment.topCenter,
                        child:  Image.asset(
                            'assets/vakinha.png'
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Muh',
                          style: TextStyle(
                              fontSize: 35.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0,),

                      TextFormField(
                          controller: _emailController,
                          validator: (text){
                            if(text.isEmpty || !text.contains("@")) return 'Email invalido';
                          },
                          decoration: new InputDecoration(
                              hintText: "Email",
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0),
                                ),
                              ),
                              filled: true,

                              fillColor: Colors.white70
                          )
                      ),


                      SizedBox(height: 10.0,),
                      TextFormField(
                          obscureText: true,
                          validator: (text){
                            if(text.isEmpty|| text.length < 4) return 'Senha inválida!';
                          },
                          controller: _passController,
                          decoration: new InputDecoration(
                              hintText: "Senha",
                              border: new OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(20.0),
                                ),
                              ),
                              filled: true,

                              fillColor: Colors.white70
                          )
                      ),
                      SizedBox(height: 8.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: FlatButton(
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SignUpScreen()));
                              },
                              child: Text(
                                'Cadastrar',
                                style: TextStyle(
                                    fontSize: 16.0
                                ),
                                textAlign: TextAlign.left,),
                              padding:EdgeInsets.zero,

                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FlatButton(
                              onPressed: (){
                                if(_emailController.text.isEmpty){
                                  ColoqueEmail();
                                }else{
                                  model.recoverPass(_emailController.text);
                                  ConfiraEmail();
                                }
                              },
                              child: Text('Esqueci minha senha',
                                style: TextStyle(
                                    fontSize: 16.0
                                ),
                                textAlign: TextAlign.right,),
                              padding:EdgeInsets.zero,
                            ),
                          ),


                        ],
                      ),
                      SizedBox(height: 10.0,),
                      ButtonTheme(
                        minWidth: 80.0,
                        height: 50.0,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide(color: Colors.black)
                          ),
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                                fontSize: 25.0
                            ),
                          ),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: (){
                            if(_formKey.currentState.validate()){
                              model.SignOut();
                              model.pegaNomedeumaFazenda();
                              model.RetornarNome();
                              model.Publicacoes();
                              this.name = model.nome;
                              model.signIn(
                                  email: _emailController.text,
                                  pass: _passController.text,
                                  onSuccess: _onSuccess,
                                  onFail: _onFail
                              );
                            }

                          },
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: FlatButton(
                      //     onPressed: (){
                      //      Navigator.of(context).push(
                      //        MaterialPageRoute(builder: (context) => GridVisitanteScreen()),
                      //       );
                      //     },
                      //     child: Text(
                      //       'Entrar como visitante',
                      //       style: TextStyle(
                      //           fontSize: 16.0
                      //       ),
                      //       textAlign: TextAlign.left,),
                      //     padding:EdgeInsets.zero,
                      //
                      //   ),
                      // ),
                    ],
                  ),
                );
              }
            },
          )
      ),
    );
  }

  void ConfiraEmail(){
    AlertDialog alert = AlertDialog(
      title: Text("Aviso"),
      content: Text("Confira o seu email!"),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void ColoqueEmail(){
    AlertDialog alert = AlertDialog(
      title: Text("Aviso!"),
      content: Text("Coloque o seu email no campo E-mail!"),
      actions: [
        FlatButton(
          child: Text('OK'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }


  void _onSuccess(){
    print(this.name.length);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => FeedScreen()),
    );
}
  void _onFail(){
    AlertDialog alert = AlertDialog(
      title: Text("Erro ao fazer o login"),
      content: Text("Verifique seu email e senha"),
      actions: [
        FlatButton(
          child: Text('Tente Novamente'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
    //exibe o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}