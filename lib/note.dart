class Note{ 
  final int id; 
  final String description;
   
  Note({required this.id, required this.description});
  
  Note.fromMap(Map<String, dynamic> item): 
    id=item["id"], description= item["description"];
  
  Map<String, Object> toMap(){
    return {'id':id,'description': description};
  }
}