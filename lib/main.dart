
import 'package:database_app/database.dart';
import 'package:database_app/database_helper.dart';
import 'package:database_app/dog.dart';
import 'package:database_app/note.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
   @override
  Widget build(BuildContext context) {
      return MaterialApp(
         title: 'Flutter Demo',
        theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
      );
  }
}

class MyHomePage extends StatefulWidget{
  
  @override
  State<MyHomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<MyHomePage> {

  List<Map<String, dynamic>> myData = [];
  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshData() async {
    final data = await Database_Helper.getItems();
    setState(() {
      myData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData(); // Loading the data when the app starts
  }

   final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();


 

  @override
  Widget build(BuildContext context) {

    
    // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  

  // Insert a new data to the database
  Future<void> addItem() async {
    await Database_Helper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Update an existing data
  Future<void> updateItem(int id) async {
    await Database_Helper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshData();
  }

  // Delete an item
  void deleteItem(int id) async {
    await Database_Helper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    backgroundColor:Colors.green
    ));
    _refreshData();
  }

      void showMyForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingData =
          myData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descriptionController.text = existingData['description'];
    }

    showModalBottomSheet(
       context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new data
                      if (id == null) {
                        await addItem();
                      }

                      if (id != null) {
                        await updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _descriptionController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }


      return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite CRUD'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : myData.isEmpty?const Center(child:  Text("No Data Available!!!")):  ListView.builder(
              itemCount: myData.length,
              itemBuilder: (context, index) => Card(
                color:index%2==0?Colors.green: Colors.green[200],
                margin: const EdgeInsets.all(15),
                child:ListTile(
                    title: Text(myData[index]['title']),
                    subtitle: Text(myData[index]['description']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => showMyForm(myData[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                deleteItem(myData[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => showMyForm(null),
      ),
    );
  }

}

