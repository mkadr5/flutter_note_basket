class Notes {
  int noteID;
  int catID;
  String noteTitle;
  String noteContent;
  String noteDate;
  String catTitle;
  int notePriority;
  Notes(
    this.catID,
    this.noteTitle,
    this.noteContent,
    this.noteDate,
    this.notePriority,
  );
  Notes.withID(
    this.noteID,
    this.catID,
    this.noteTitle,
    this.noteContent,
    this.noteDate,
    this.notePriority,
  );

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['noteID'] = noteID;
    map['catID'] = catID;
    map['noteTitle'] = noteTitle;
    map['noteContent'] = noteContent;
    map['noteDate'] = noteDate;
    map['notePriority'] = notePriority;

    return map;
  }

  Notes.fromMap(Map<String, dynamic> map) {
    this.noteID = map['noteID'];
    this.catID = map['catID'];
    this.noteTitle = map['noteTitle'];
    this.noteContent = map['noteContent'];
    this.noteDate = map['noteDate'];
    this.catTitle = map['catTitle'];
    this.notePriority = map['notePriority'];
  }
  @override
  String toString() {
    return 'Notes(noteID: $noteID, catID: $catID, noteTitle: $noteTitle, noteContent: $noteContent, noteDate: $noteDate, notePriority: $notePriority)';
  }
}
