import 'package:flutter/material.dart';
import 'package:flutter_note_basket/main.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  String title;
  Notes editedNote;
  NoteDetail({this.title, this.editedNote});
  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();
  List<Category> allCategory;
  DatabaseHelper databaseHelper;
  int categoryID;
  int selectedPriorityID;
  String noteTitle, noteContent;
  static var _priority = ["Low", "Middle", "High"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCategory = List<Category>();
    databaseHelper = DatabaseHelper();
    databaseHelper.getCategory().then((value) {
      for (Map items in value) {
        allCategory.add(Category.fromMap(items));
      }

      if (widget.editedNote != null) {
        categoryID = widget.editedNote.catID;
        selectedPriorityID = widget.editedNote.notePriority;
      } else {
        categoryID = 1;
        selectedPriorityID = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: allCategory.length <= 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Category :",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Container(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              items: createCategoryItems(),
                              hint: Text("Select Category"),
                              value: categoryID,
                              onChanged: (selectedCatID) {
                                setState(() {
                                  categoryID = selectedCatID;
                                });
                              },
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: TextFormField(
                        initialValue: widget.editedNote != null
                            ? widget.editedNote.noteTitle
                            : "",
                        validator: (textv) {
                          if (textv.length < 3) {
                            return "Please enter at least 3 characters!";
                          }
                        },
                        onSaved: (textv) {
                          noteTitle = textv;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter note title",
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: TextFormField(
                        initialValue: widget.editedNote != null
                            ? widget.editedNote.noteContent
                            : "",
                        onSaved: (textv) {
                          noteContent = textv;
                        },
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Enter note content",
                          labelText: "Content",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25),
                          child: Text(
                            "Priority :",
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        Container(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              items: _priority.map((e) {
                                return DropdownMenuItem<int>(
                                  child: Text(
                                    e,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  value: _priority.indexOf(e),
                                );
                              }).toList(),
                              hint: Text("Select Priority"),
                              value: selectedPriorityID,
                              onChanged: (selectedPrioID) {
                                setState(() {
                                  selectedPriorityID = selectedPrioID;
                                });
                              },
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.redAccent, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ButtonBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyApp()));
                          },
                          child: Text('Cancel'),
                          color: Colors.redAccent.shade200,
                        ),
                        RaisedButton(
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              var now = DateTime.now();
                              if (widget.editedNote == null) {
                                databaseHelper
                                    .insertNotes(Notes(
                                        categoryID,
                                        noteTitle,
                                        noteContent,
                                        now.toString(),
                                        selectedPriorityID))
                                    .then((value) {
                                  if (value != 0) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }
                                });
                              } else {
                                databaseHelper
                                    .updateNotes(Notes.withID(
                                        widget.editedNote.noteID,
                                        categoryID,
                                        noteTitle,
                                        noteContent,
                                        now.toString(),
                                        selectedPriorityID))
                                    .then((value) {
                                  if (value != 0) {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MyApp()));
                                  }
                                });
                              }
                            }
                          },
                          child: Text('Save'),
                          color: Colors.redAccent.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  List<DropdownMenuItem<int>> createCategoryItems() {
    List<DropdownMenuItem<int>> categorys = [];
    return allCategory
        .map(
          (e) => DropdownMenuItem<int>(
            value: e.catID,
            child: Text(
              e.caTitle,
              style: TextStyle(fontSize: 20),
            ),
          ),
        )
        .toList();
  }
}
/*

 Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                child: DropdownButtonHideUnderline(
                  child: allCategory.length <= 0
                      ? CircularProgressIndicator()
                      : DropdownButton<int>(
                          items: createCategoryItems(),
                          onChanged: (selectedCatID) {
                            setState(() {
                              categoryID = selectedCatID;
                            });
                          },
                          value: categoryID,
                        ),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 48),
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

*/
