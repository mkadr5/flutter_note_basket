class Category {
  int catID;
  String caTitle;
  Category(this.caTitle);
  Category.withID(this.catID, this.caTitle);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['catID'] = catID;
    map['catTitle'] = caTitle;
    return map;
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.catID = map['catID'];
    this.caTitle = map['catTitle'];
  }
  @override
  String toString() {
    // TODO: implement toString
    return 'Category{catiID: $catID, catTitle: $caTitle}';
  }
}
