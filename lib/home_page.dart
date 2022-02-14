// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:learn_sqlite_flutter2/Database/sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> list_data = [];
  bool _is_loading = true;

  TextEditingController _controller_title = TextEditingController();
  TextEditingController _controller_description = TextEditingController();

  void _refreshData() async {
    final data = await SqlHelper.getAllData();
    setState(() {
      list_data = data;
      _is_loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _showForms(int? id) {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final exist_data = list_data.firstWhere((element) => element['id'] == id);
      _controller_title.text = exist_data['title'];
      _controller_description.text = exist_data['description'];
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your New Word'),
            content: Column(children: [
              TextField(
                controller: _controller_title,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _controller_description,
                decoration: InputDecoration(hintText: 'description'),
              ),
            ]),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text(id == null ? 'Create New' : 'Update'),
                onPressed: () {
                  setState(
                    () async {
                      if (id == null) {
                        await _addItem();
                      }
                      if (id != null) {
                        await _updateItem(id);
                      }

                      //clear textField
                      _controller_title.text = '';
                      _controller_description.text = '';

                      //close bottomSheet
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ],
          );
        });

/*
    showModalBottomSheet(
              context: context,
              elevation: 5,
              isScrollControlled: true,
              builder: (_) => Container(
                    height: 300,
                    padding: EdgeInsets.only(
                      top: 15,
                      right: 15,
                      left: 15,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10.0),
                            topLeft: Radius.circular(10.0))),
                    child: Column(
                      children: [
                        TextField(
                           controller: _controller_title,
                          decoration: InputDecoration(hintText: 'Title'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: _controller_description,
                          decoration: InputDecoration(hintText: 'description'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              
                              if (id == null) {
                                await _addItem();
                              }
                              if (id != null) {
                                await _updateItem(id);
                              }

                              //clear textField
                              _controller_title.text = '';
                              _controller_description.text = '';

                              //close bottomSheet
                              Navigator.of(context).pop();
                            },
                            child: Text(id == null ? 'Create New' : 'Update'))
                      ],
                    ),
                  ));
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Sqlite Project in FLutter'),
        centerTitle: true,
      ),
      body: _is_loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: list_data.length,
              itemBuilder: (context, index) {
                return Card(
                    color: Colors.yellow[400],
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                        title: Text(list_data[index]['title']),
                        subtitle: Text(list_data[index]['description']),
                        trailing: SizedBox(
                            width: 100.0,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      _showForms(list_data[index]['id']);
                                    },
                                    icon: Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      _deleteItem(list_data[index]['id']);
                                    },
                                    icon: Icon(Icons.delete))
                              ],
                            ))));
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForms(null);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  //insert Data
  Future<void> _addItem() async {
    await SqlHelper.insertData(
        _controller_title.text, _controller_description.text);
    var snackBar = SnackBar(
      content: Text('SuccessFully Add Item'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _refreshData();
  }

//update item
  Future<void> _updateItem(int id) async {
    await SqlHelper.updateItem(
        id, _controller_title.text, _controller_description.text);
    _refreshData();
  }

//delete Item
  void _deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    var snackBar = SnackBar(
        content: Text('Successfully Delete Item '),
        backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    _refreshData();
  }
}
