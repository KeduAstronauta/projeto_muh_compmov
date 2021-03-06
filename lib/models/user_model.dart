import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

class UserModel extends Model{

  FirebaseAuth _auth = FirebaseAuth.instance;
  List nome = [];
  List produtos = []; // products
  List produtosId = [];
  String idFazenda;
  FirebaseUser firebaseUser;
  Map<String,dynamic> userData = Map();
  List id = [];
  int indice;
  String nome_identificacao;
  String email;

  List preco = [];
  List descricao = [];
  List imagem = [];
  List datas = [];

  String background_image;

  bool condicional = false;


  bool isLoading = false;

  static UserModel of(BuildContext context)=>
      ScopedModel.of<UserModel>(context);


  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _loadCurrentUser();
  }

  void signUp({@required Map<String,dynamic> userData,@required String pass,
    @required VoidCallback onSuccess,@required VoidCallback onFail}){
    isLoading = true;
    notifyListeners();

    _auth.createUserWithEmailAndPassword(
        email: userData['email'],
        password: pass
    ).then((value) async {
      firebaseUser = value;
      await _saveUserData(userData);
      onSuccess();
      isLoading = false;
      notifyListeners();
    }).catchError((onError){
      onFail();
      isLoading = false;
      notifyListeners();
    });
  }

  void signIn({@required String email,@required String pass,
    @required VoidCallback onSuccess,@required VoidCallback onFail})async{
    isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 3));

    isLoading = false;
    notifyListeners();
    _auth.signInWithEmailAndPassword(email: email, password: pass).then((value) async {

      firebaseUser = value;
      await _loadCurrentUser();
      onSuccess();
      isLoading = false;
      notifyListeners();

    }).catchError((onError){

      onFail();
      isLoading = false;
      notifyListeners();

    });
  }

  void recoverPass(String email){
    _auth.sendPasswordResetEmail(email: email);
  }

  Future<Null> _saveUserData(Map<String,dynamic> userData) async {
    this.userData = userData;
    await Firestore.instance.collection('users').document(firebaseUser.uid).setData(userData);
  }

  Future<String> updateImage(File image) async {
    if (image != null) {
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
          DateTime
              .now()
              .millisecondsSinceEpoch
              .toString()
      ).putFile(image);
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    }
    return "";
  }
  
  Future<List<DocumentSnapshot>> getUsers() async {
    QuerySnapshot q = await Firestore.instance.collection("users").getDocuments();
    return q.documents;
  }
  
  Future<List<DocumentSnapshot>> getUserPublication(String userId) async {
    QuerySnapshot q = await Firestore.instance.collection("users").document(userId).collection("publicacao").getDocuments();
    return q.documents;
  }

  Future<Null> Publicacoes() async{
    this.imagem.clear();
    this.descricao.clear();
    this.preco.clear();
    print("Cheguei aqui");

    List descricao = [];
    List imagem =  [];
    List preco = [];
    List datas = [];

    QuerySnapshot query = await Firestore.instance.collection('users').document(firebaseUser.uid).collection('publicacao').getDocuments();
    print("Cheguei aqui");
    for(DocumentSnapshot item in query.documents) {
      var dados = item.data;
      descricao.add(dados["descrição"]);
      imagem.add(dados["image"]);
      preco.add(dados["preço"]);

      print("descricao: " + dados["descrição"]);
      print("Imagem: " + dados["image"]);
      print("Preco: " + dados["preço"]);
      datas.add(dados["formatted"]);
    }

    print("Tamanho das listas: " + datas.length.toString());
    print("Tamanho das listas: " + preco.length.toString());
    print("Tamanho das listas: " + descricao.length.toString());
    print("Tamanho das listas: " + imagem.length.toString());

    this.descricao = descricao;
    this.preco = preco;
    this.imagem = imagem;
    this.datas = datas;

    print("Tamanho das listas: " + this.datas.length.toString());
    print("Tamanho das listas: " + this.preco.length.toString());
    print("Tamanho das listas: " + this.descricao.length.toString());
    print("Tamanho das listas: " + this.imagem.length.toString());

  }

  Future<Null> getLikes(Map<String,dynamic> farmData, String idFarm) async {

  }

  Future<Null> createProdutoData(Map<String,dynamic> farmData, String idFarm) async {
    await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document(idFarm).collection("products").document().setData(farmData);
  }

  Future<Null> createFarmData(Map<String,dynamic> farmData, File image) async {
    String url = await updateImage(image);
    farmData.update('image', (value) => value = url);
    await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document().setData(farmData);
  }
  
  Future<Null> newPublication(Map<String,dynamic> pub, File image) async {
    String imagem = await updateImage(image);
    pub.update('image', (value) => value = imagem);
    await Firestore.instance.collection('users').document(firebaseUser.uid).collection('publicacao').document().setData(pub);
  } // AMANDA

  Future<Null> getPublication(String id, String nome) async {
    DocumentSnapshot publication = await Firestore.instance.collection('users').document(firebaseUser.uid).collection('publicacao').document(id).get();
    var dado = (publication.data);
    String desc = dado['descrição'];
    String data = dado['formatted'];
    String img  = dado['image'];
    String prec = dado['preço'];
    return (desc + data +img+prec);
  } // AMANDA

  Future<Null> generalPublication(Map<String,dynamic> pub, File image) async {
    String imagem = await updateImage(image);
    pub.update('image', (value) => value = imagem);
    await Firestore.instance.collection('publications').document().setData(pub);
  }

  Future<String> pegaItensdeumaFazenda() async{ // retorna os itens da fazenda da tela do gu
    DocumentSnapshot fazenda = await Firestore.instance.collection('users').document(firebaseUser.uid).collection('farms').document().get();
    String nome = fazenda.data['name'];
    return nome;
  }

  Future<Null> criarTipo(String idFarm, Map<String,dynamic> idtag,  File image) async {
    await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document(idFarm).collection("products").document().setData(idtag);
  }

  Future<String> criaProduto(Map<String, dynamic> produtos, File image, String id_fazenda) async {
    String url = await updateImage(image);
    produtos.update('image', (value) => value = url);
    var item = await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document(id_fazenda).collection('products').document();
    item.setData(produtos);
    return item.documentID;
  }

  Future<Null> AddImagemUser(File image) async{

    String id = await Firestore.instance.collection('users').document(firebaseUser.uid).documentID;
    String url = await updateImage(image);
    String data = "";
    String email = "";
    String genero = "";
    String imagem = "";
    String lastname = "";
    String nome = "";

    QuerySnapshot query = await Firestore.instance.collection('users').getDocuments();
    for(DocumentSnapshot item in query.documents) {
      var dados = item.data;
      if(id == item.documentID) {
        data = dados["bithday"];
        email = dados["email"];
        genero = dados["genre"];
        imagem = url;
        lastname = dados["lastname"];
        nome = dados["name"];
      }
    }

    Map<String,dynamic> perfil_novo = {
      'name': nome,
      'bithday': data,
      'email': email,
      'genero': genero,
      'image': imagem,
      'lastname' : lastname,
    };

    await Firestore.instance.collection('users').document(firebaseUser.uid).setData(perfil_novo);

    this.background_image = imagem;

  }


  Future<List> pegaNomedeumaFazenda() async{
    nome.clear();
    QuerySnapshot query = await Firestore.instance.collection('users').document(firebaseUser.uid).collection('farms').getDocuments();
    for(DocumentSnapshot item in query.documents) {
      var dados = item.data;
      print("nome12121212121: " + dados["name"]);
      String aux = dados["name"];
      nome.add(aux);
      id.add(item.documentID);
      print("\n\n\n\n\n dados: " + item.documentID);
      idFazenda = item.documentID;
    }

  }

  Future removeItem(String idFazenda, String idProduto, String idItem) async {
    var firestore = Firestore.instance;

    // Retorna todos os items do produto selecionado
    await firestore.collection("users").document(firebaseUser.uid)
        .collection("farms").document(idFazenda)
        .collection("products").document(idProduto)
        .collection("items").document(idItem).delete()
        .then((value) => print("Item: " + idItem + " removido com sucesso!"))
        .catchError((error) => print("Item: " + idItem + " não pode ser removido..."));
  }

  Future<List<DocumentSnapshot>> getItems(String idFazenda, String idProduto) async {
    var firestore = Firestore.instance;

    // Retorna todos os items do produto selecionado
    QuerySnapshot qn = await firestore.collection("users").document(firebaseUser.uid).collection("farms").document(idFazenda).collection("products").document(idProduto).collection("items").getDocuments();

    return qn.documents;
  }

  int RetornaIndiceProduto(String NomeFazenda){
    print("chegou aqui" + NomeFazenda);
    print("chegou aqui" + this.nome.length.toString());
    int indice = 0;
    for(int i=0; i<this.nome.length;i++){
      if(this.nome[i].toString() == NomeFazenda){
        print("Nome da fazenda:" + this.nome[i]);
        print("Id da fazenda:" + this.id[i]);
        indice = i;
        break;
      }
    }
    return indice;
  }

  Future<Null> RetornarNome() async{
    String nome = "";
    String id = await Firestore.instance.collection('users').document(firebaseUser.uid).documentID;
    QuerySnapshot query = await Firestore.instance.collection('users').getDocuments();
    //print("teste de nome: " + teste);
    String sobrenome = "";
    String email1 = "";
    String imagem;
    for(DocumentSnapshot item in query.documents){
      var dado = item.data;
      if(id == item.documentID){
        //print("dado ajshkjasa: " + item.documentID);
         print("nome12121212121: " + dado["name"]);
         nome = dado["name"];
         sobrenome = dado["lastname"];
         print("nome12121212121: " + dado["lastname"]);
         email1 = dado["email"];
         imagem = dado["image"];
      }

    }
    print("askujhsjkas");
    this.email = email1;
    this.nome_identificacao = nome + " " + sobrenome;
    this.background_image = imagem;
  }

  Future<Null> pegaNomedosProdutos(String idFazenda) async{ // retorna os itens da fazenda da tela do gu
    indice = RetornaIndiceProduto(idFazenda);
    String idFa = this.id[indice];
    //produtos.clear();
    QuerySnapshot query = await Firestore.instance.collection('users').document(firebaseUser.uid).collection('farms').document(idFa).collection('products').getDocuments();
    produtos.clear();
    produtosId.clear();
    for(DocumentSnapshot item in query.documents) {
      var dados = item.data;
      print("nome12121212121: " + dados["name"]);
      String aux = dados["name"];
      produtos.add(aux);
      produtosId.add(item.documentID);
      print("\n\n\n\n\n dados: " + item.documentID);
      //idFazenda = item.documentID;
    }
    if(produtos.isEmpty){
      print("N tem gente aqui");
      this.condicional = false;
    }else{
      this.condicional = true;
      print("tem gente aqui");
    }
  }

  Future<Null> createItemData(Map<String,dynamic> itemData, File image, String farmId, String IdProduto) async {
    String url = await updateImage(image);
    itemData.update('image', (value) => value = url);
    //await Firestore.instance.collection('users').document(firebaseUser.uid).collection('farms').document(farmId).collection('items').document().setData(itemData)
    //await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document(farmId).collection('items').document().setData(itemData);
   await Firestore.instance.collection('users').document(firebaseUser.uid).collection("farms").document(farmId).collection("products").document(IdProduto).collection("items").document().setData(itemData);
  }

  bool isLoggedIn(){
    return firebaseUser != null;
  }

  void SignOut() async{
    await _auth.signOut();
    userData=Map();
    firebaseUser=null;
    notifyListeners();
  }


  Future<Null> _loadCurrentUser() async{
    if(firebaseUser == null)
      firebaseUser = await _auth.currentUser();
    if(firebaseUser != null){
      if(userData['name'] == null){
        DocumentSnapshot docUser =
        await Firestore.instance.collection('users').document(firebaseUser.uid).get();
        userData = docUser.data;
      }
    }
    notifyListeners();
  }



  Future<Null> reportProblem(Map<String,dynamic> description) async {

    await Firestore.instance.collection('users').document(firebaseUser.uid).collection("Problemas Relatados").document().setData(description);
  }
}