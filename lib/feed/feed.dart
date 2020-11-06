import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:projeto_muh_compmov/feed/ifeed.dart';
import 'package:projeto_muh_compmov/utils/stateful_flat_button.dart';

class Feed implements IFeed {

  // final User __userInfo; // Informações de quem postou, link de perfil, nome e imagem de perfil.
  // final Content __publicationContent // Informações da publicação vinda do banco de dados.

  final Map userInfo; // Test
  final String text;
  final DateTime date;

  bool __favState = false; // Informação se o usuário favoritou a publicação
  bool __likeState = false; // Informação se o usuário curtiu a publicação
  // A data tem que ser de acordo com a data de publicação
  // que vem do banco de dados.
  Feed({@required this.text, @required this.userInfo})
      : this.date = DateTime.now();

  @override
  Widget render() {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            onTap: null, // Vai pro perfil
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(userInfo["image"])
                )
              ),
            ),
            title: Text(userInfo["name"]),
            subtitle: Text("Enviado em ${DateFormat("dd/MM/yyyy").format(date)}"),
          ),
          renderContent(),
          renderBottom(),
        ],
      ),
    );
  }

  @override
  Widget renderContent() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(this.text),
        ),
      ],
    );
  }

  @override
  Widget renderBottom() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        StatefulFlatButton(
          state: this.__likeState,
          iconActive: Icons.thumb_up,
          iconInactive: Icons.thumb_up,
        ),
        StatefulFlatButton(
          state: this.__favState,
          iconActive: Icons.favorite,
          iconInactive: Icons.favorite_border,
          fillColorActive: Colors.red,
        ),
        FlatButton(
            onPressed: null,
            child: Icon(Icons.comment),
        ),
        FlatButton(
            onPressed: null,
            child: Icon(Icons.share),
        ),
        FlatButton(
            onPressed: null,
            child: Icon(Icons.shopping_cart),
        )
      ],
    );
  }

}

