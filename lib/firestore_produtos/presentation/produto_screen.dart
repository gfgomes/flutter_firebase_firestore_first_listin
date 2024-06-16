import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/firestore_produtos/helpers/enum_order.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../model/produto.dart';
import 'widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;
  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  // List<Produto> listaProdutosPlanejados = [
  //   Produto(id: "ADASD", name: "Maçã", isComprado: false),
  //   Produto(id: "UUID", name: "Pêra", isComprado: false),
  // ];

  // List<Produto> listaProdutosPegos = [
  //   Produto(id: "UUID", name: "Laranja", amount: 5, price: 1, isComprado: true),
  // ];

  List<Produto> listaProdutosPlanejados = [];

  List<Produto> listaProdutosPegos = [];

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  OrdemProduto ordem = OrdemProduto.name;
  bool isDecrescente = false;

  late StreamSubscription listener;

  @override
  void initState() {
    //Removido pois o firebase avisa quando um alteração ocorre
    //refresh();
    setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    //Ao encerrar a tela, fecha a c o listener
    listener.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: OrdemProduto.name,
                  child: Text("Ordenar por nome"),
                ),
                const PopupMenuItem(
                  value: OrdemProduto.amount,
                  child: Text("Ordenar por quantidade"),
                ),
                const PopupMenuItem(
                  value: OrdemProduto.price,
                  child: Text("Ordenar por preço"),
                ),
              ];
            },
            onSelected: (value) {
              setState(
                () {
                  if (ordem == value) {
                    isDecrescente = !isDecrescente;
                  } else {
                    ordem = value;
                    isDecrescente = false;
                  }
                },
              );
              refresh();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => refresh(),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: const Column(
                children: [
                  Text(
                    "R\$${0}",
                    style: TextStyle(fontSize: 42),
                  ),
                  Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPlanejados.length, (index) {
                Produto produto = listaProdutosPlanejados[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: false,
                  showModel: showFormModal,
                  iconClick: alternarComprado,
                );
              }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(listaProdutosPegos.length, (index) {
                Produto produto = listaProdutosPegos[index];
                return ListTileProduto(
                  produto: produto,
                  isComprado: true,
                  showModel: showFormModal,
                  iconClick: alternarComprado,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(labelTitle,
                  style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        produto.id = model.id;
                      }

                      if (amountController.text != "") {
                        produto.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        produto.price = double.parse(priceController.text);
                      }

                      // Salva no Firestore
                      firestore
                          .collection("listins")
                          .doc(widget.listin.id)
                          .collection("produtos")
                          .doc(produto.id)
                          .set(produto.toMap());

                      //Removido pois o firebase avisa quando um alteração ocorre
                      // Atualizar a lista
                      //refresh();

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> temp = [];

    snapshot ??= await firestore
        .collection("listins")
        .doc(widget.listin.id)
        .collection("produtos")
        //.where("isComprado", isEqualTo: isComprado)
        .orderBy(ordem.name, descending: isDecrescente)
        .get();

    verificaAlteracoes(snapshot);

    for (var doc in snapshot.docs) {
      temp.add(Produto.fromMap(doc.data()));
    }
    filtrarProdutos(temp);
  }

  filtrarProdutos(List<Produto> listProdutos) {
    List<Produto> temPlanejados = [];
    List<Produto> temPegos = [];

    for (var produtoItem in listProdutos) {
      if (produtoItem.isComprado) {
        temPegos.add(produtoItem);
      } else {
        temPlanejados.add(produtoItem);
      }
    }

    setState(() {
      listaProdutosPlanejados = temPlanejados;
      listaProdutosPegos = temPegos;
    });
  }

  alternarComprado(Produto produto) async {
    produto.isComprado = !produto.isComprado;

    await firestore
        .collection("listins")
        .doc(widget.listin.id)
        .collection("produtos")
        .doc(produto.id)
        .update({"isComprado": produto.isComprado});

    //Removido pois o firebase avisa quando um alteração ocorre
    //refresh();
  }

  setupListeners() {
    listener = firestore
        .collection("listins")
        .doc(widget.listin.id)
        .collection("produtos")
        .orderBy(ordem.name, descending: isDecrescente)
        .snapshots()
        .listen((snapshot) {
      refresh(snapshot: snapshot);
    });
  }

  verificaAlteracoes(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (var change in snapshot.docChanges) {
        String tipoAlteracao = "";
        Color cor = Colors.green;
        switch (change.type) {
          case DocumentChangeType.added:
            //print("New City: ${change.doc.data()}");
            tipoAlteracao = "Produto adicionado:";
            break;
          case DocumentChangeType.modified:
            tipoAlteracao = "Produto alterado:";
            cor = Colors.yellow;
            break;
          case DocumentChangeType.removed:
            tipoAlteracao = "Produto removido:";
            cor = Colors.red;
            break;
        }
        Produto produto = Produto.fromMap(change.doc.data()!);
        final snackBar = SnackBar(
          backgroundColor: cor,
          content: Text("$tipoAlteracao ${produto.name}"),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
