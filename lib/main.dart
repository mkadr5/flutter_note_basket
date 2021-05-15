import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_note_basket/category_operations.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:flutter_note_basket/note_detail.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Note Basket',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();
  var _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    debugPrint("yenilendi1");
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text("Note Basket"),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.category),
                  title: Text("Categorys"),
                  onTap: () {
                    Navigator.pop(context);
                    _runCategorysPage(context);
                  },
                ),
              )
            ];
          }),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addCat",
            onPressed: () {
              addCategoryMethod(context);
            },
            tooltip: "Add Category",
            child: Icon(Icons.add_circle),
            mini: true,
          ),
          FloatingActionButton(
            heroTag: "addNote",
            onPressed: () => _gotoDetailPage(context),
            tooltip: "Add Note",
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: NotesList(),
    );
  }

  Future addCategoryMethod(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String newCatName;
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Add Category",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Form(
                key: formKey,
                child: TextFormField(
                  onSaved: (newValue) {
                    newCatName = newValue;
                  },
                  decoration: InputDecoration(
                    labelText: "Category Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (inputCatName) {
                    if (inputCatName.length < 3) {
                      return "Please enter at least 3 characters!";
                    }
                  },
                ),
              ),
            ),
            ButtonBar(
              children: [
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.orangeAccent,
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      databaseHelper
                          .insertCategory(Category(newCatName))
                          .then((newCatID) {
                        if (newCatID > 0) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Category Added"),
                            duration: Duration(seconds: 2),
                          ));
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  color: Colors.redAccent,
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _gotoDetailPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetail(
          title: "New Note",
        ),
      ),
    );
  }

  void _runCategorysPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CategoryPage()));
  }
}

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  List<Notes> allNotes;
  DatabaseHelper databaseHelper;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allNotes = List<Notes>();
    databaseHelper = DatabaseHelper();
    print("yenilendi");
    setState(() {
      debugPrint("yenilendi2");
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("yenilendi3");
    return FutureBuilder(
      future: databaseHelper.getNoteList(),
      builder: (BuildContext context, AsyncSnapshot<List<Notes>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          allNotes = snapshot.data;
          sleep(Duration(milliseconds: 500));
          debugPrint("yenilendi4");
          return ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (context, int index) {
                return ExpansionTile(
                  leading: _createPriorityIcon(allNotes[index].notePriority),
                  title: Text(allNotes[index].noteTitle),
                  subtitle: Text(allNotes[index].catTitle),
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "Category",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  allNotes[index].catTitle,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "Create Date",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  databaseHelper.dateFormat(
                                    DateTime.parse(allNotes[index].noteDate),
                                  ),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              "Content : \n" + allNotes[index].noteContent,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FlatButton(
                                  onPressed: () =>
                                      _noteDelete(allNotes[index].noteID),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                              FlatButton(
                                  onPressed: () {
                                    _gotoDetailPageUpdate(
                                        context, allNotes[index]);
                                  },
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.green),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              });
        } else {
          debugPrint("yenilendi5");
          return Center(
            child: Center(
              child: Text("Yükleniyor"),
            ),
          );
        }
      },
    );
  }

  _gotoDetailPageUpdate(BuildContext context, Notes note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NoteDetail(title: "Note Update", editedNote: note),
      ),
    );
  }

  _createPriorityIcon(int notePriority) {
    debugPrint("yenilendi6");
    switch (notePriority) {
      case 0:
        return CircleAvatar(
          child: Text("Low", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade100,
        );
        break;
      case 1:
        return CircleAvatar(
          child: Text(
            "Mid",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade200,
        );
        break;
      case 2:
        return CircleAvatar(
          child: Text("High", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent.shade700,
        );
        break;
      default:
    }
  }

  _noteDelete(int noteID) {
    databaseHelper.deleteNotes(noteID).then((value) {
      if (value != 0) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Note Deleted")));
        setState(() {});
      }
    });
  }
}
