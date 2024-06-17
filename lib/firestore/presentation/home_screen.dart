import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_firestore_first/authentication/component/show_senha_confirmacao_dialog.dart';
import 'package:flutter_firebase_firestore_first/authentication/services/auth_service.dart';
import 'package:flutter_firebase_firestore_first/firestore/helpers/firestore_analytics.dart';
import 'package:flutter_firebase_firestore_first/firestore/services/listin_service.dart';
import 'package:flutter_firebase_firestore_first/firestore_produtos/presentation/produto_screen.dart';
import 'package:uuid/uuid.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];

  //FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirestoreAnalytics analytics = FirestoreAnalytics();
  ListinService listinService = ListinService();

  @override
  void initState() {
    refresh();
    analytics.incrementarAcessosTotais();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Listin - Feira Colaborativa",
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text("Remover conta"),
                onTap: () {
                  //AuthService().removeConta();
                  showSenhaConfirmacaoDialog(context: context, email: "email");
                }),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
              onTap: () {
                AuthService().deslogar();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                analytics.incrementarAtualizacoesManuais();
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  listListins.length,
                  (index) {
                    Listin model = listListins[index];
                    return Dismissible(
                      key: ValueKey<Listin>(model),
                      direction: DismissDirection.endToStart,
                      background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          )),
                      onDismissed: (direction) {
                        listinService.removeListin(model);
                      },
                      child: ListTile(
                        onTap: () {
                          //Quando clicar em um Listin
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProdutoScreen(listin: model),
                            ),
                          );
                        },
                        onLongPress: () {
                          //Quando pressiona um Listin
                          showFormModal(model: model);
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        //subtitle: Text(model.id),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";
    TextEditingController nameController = TextEditingController();

    if (model != null) {
      title = "Edidando ${model.name}";
      nameController.text = model.name;
      confirmationButton = "Alterar";
    }

    // Controlador do campo que receberá o nome do Listin

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
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
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Listin saveListin = Listin(
                          id: const Uuid().v1(),
                          name: nameController.text,
                        );

                        if (model != null) {
                          saveListin.id = model.id;
                        }

                        //Salavar no Firestore
                        listinService.adicionarListin(saveListin);

                        analytics.incrementarListasAdicionadas();

                        refresh();
                        //Fecha o modal
                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Listin> temp = await listinService.lerListins();

    // listListins = (await firestore.collection("listins").get())
    //     .docs
    //     .map((doc) => Listin.fromMap(doc.data()))
    //     .toList();
    // QuerySnapshot<Map<String, dynamic>> snapshot =
    //     await firestore.collection("listins").get();

    // for (var doc in snapshot.docs) {
    //   temp.add(Listin.fromMap(doc.data()));
    // }

    setState(() {
      listListins = temp;
    });
  }
}
