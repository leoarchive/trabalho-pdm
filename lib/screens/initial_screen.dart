import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/task.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  double opacity = 1.0;
  ValueNotifier<bool> openCloseDial = ValueNotifier(false);

  final TextEditingController nameController = TextEditingController();
  int selectedDifficulty = 1;

  void _showAddTaskDialog() {
    String imageUrl = '';
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final imageController = TextEditingController();
        int selectedDifficulty = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Nova Tarefa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(labelText: 'URL da Imagem'),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              selectedDifficulty = index + 1;
                            });
                          },
                          icon: Icon(
                            index < selectedDifficulty
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text;
                    final image = imageController.text;

                    if (name.isNotEmpty &&
                        image.isNotEmpty &&
                        selectedDifficulty > 0) {
                      await FirebaseFirestore.instance.collection('Tasks').add({
                        'name': name,
                        'image': image,
                        'difficulty': selectedDifficulty,
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarefas')),
      body: AnimatedOpacity(
        opacity: opacity,
        duration: Duration(milliseconds: 1000),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Tasks').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            final tasks = snapshot.data!.docs;

            if (tasks.isEmpty) {
              return Center(
                child: Text(
                  'Nenhuma tarefa encontrada.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView(
              children:
                  tasks.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Task(
                      data['name'] ?? 'Sem nome',
                      data['image'] ?? 'https://via.placeholder.com/150',
                      data['difficulty'] ?? 1,

                      data['onDelete'] = () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Excluir tarefa'),
                                content: Text(
                                  'Tem certeza que deseja excluir "${data['name']}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: Text('Excluir'),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          await doc.reference.delete();
                        }
                      },
                      data['onEdit'] = () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final nameController = TextEditingController(
                              text: data['name'],
                            );
                            final imageController = TextEditingController(
                              text: data['image'],
                            );
                            int selectedDifficulty = data['difficulty'];

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AlertDialog(
                                  title: Text('Editar Tarefa'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            labelText: 'Nome',
                                          ),
                                        ),
                                        TextField(
                                          controller: imageController,
                                          decoration: InputDecoration(
                                            labelText: 'URL da Imagem',
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            return IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedDifficulty =
                                                      index + 1;
                                                });
                                              },
                                              icon: Icon(
                                                index < selectedDifficulty
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await doc.reference.update({
                                          'name': nameController.text,
                                          'image': imageController.text,
                                          'difficulty': selectedDifficulty,
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('Salvar'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        children: [
          SpeedDialChild(
            shape: const CircleBorder(),
            child: Icon(Icons.remove_red_eye),
            onTap: () {
              setState(() => opacity = opacity == 1.0 ? 0.0 : 1.0);
            },
          ),
          SpeedDialChild(
            shape: const CircleBorder(),
            child: Icon(Icons.delete),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Excluir todas as tarefas?'),
                      content: Text(
                        'Essa ação é irreversível. Deseja continuar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Excluir'),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                final tasks =
                    await FirebaseFirestore.instance.collection('Tasks').get();
                for (final doc in tasks.docs) {
                  await doc.reference.delete();
                }
              }
            },
          ),
          SpeedDialChild(
            shape: const CircleBorder(),
            child: Icon(Icons.add),
            onTap: _showAddTaskDialog,
          ),
        ],
        icon: (openCloseDial.value ? Icons.expand_more : Icons.expand_less),
        openCloseDial: openCloseDial,
        onClose: () => setState(() => openCloseDial.value = false),
        onPress: () => setState(() => openCloseDial.value = true),
      ),
    );
  }
}
