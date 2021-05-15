import 'package:flutter/material.dart';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/utils/database_helper.dart';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> allCategory;
  DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseHelper = DatabaseHelper();
  }

  @override
  Widget build(BuildContext context) {
    if (allCategory == null) {
      allCategory = List<Category>();
      updateCategoryList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorys"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: allCategory.length,
          itemBuilder: (context, int index) {
            return ListTile(
              title: Text(allCategory[index].caTitle),
              trailing: InkWell(
                child: Icon(Icons.delete),
                onTap: () => _deleteCategory(allCategory[index].catID),
              ),
              leading: Icon(Icons.category),
              onTap: () => _updateeCategory(allCategory[index], context),
            );
          },
        ),
      ),
    );
  }

  void updateCategoryList() {
    databaseHelper.getCategoryList().then((value) {
      setState(() {
        allCategory = value;
      });
    });
  }

  _deleteCategory(int catID) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Category"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    "It will be deleted in the notes related to the category. Are you sure you want to delete the category?"),
                ButtonBar(
                  children: [
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel")),
                    FlatButton(
                      onPressed: () {
                        databaseHelper.deleteCategory(catID).then((value) {
                          if (value != 0) {
                            setState(() {
                              updateCategoryList();
                              Navigator.pop(context);
                            });
                          }
                        });
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  _updateeCategory(Category category, BuildContext c) {
    updateCategoryMethod(c, category);
  }

  Future updateCategoryMethod(BuildContext mycontext, Category upcategory) {
    var formKey = GlobalKey<FormState>();
    String newCatName;
    return showDialog(
      barrierDismissible: false,
      context: mycontext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "Update Category",
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Form(
                key: formKey,
                child: TextFormField(
                  initialValue: upcategory.caTitle,
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
                          .updateCategory(
                              Category.withID(upcategory.catID, newCatName))
                          .then((value) {
                        if (value != 0) {
                          Scaffold.of(mycontext).showSnackBar(SnackBar(
                            content: Text("Category Updated"),
                            duration: Duration(seconds: 1),
                          ));
                          updateCategoryList();
                          Navigator.pop(context);
                        }
                      });
                      /*databaseHelper
                          .insertCategory(Category(newCatName))
                          .then((newCatID) {
                        if (newCatID > 0) {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text("Category Added"),
                            duration: Duration(seconds: 2),
                          ));
                          Navigator.pop(context);
                        }
                      });*/
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
}
