// ignore_for_file: unnecessary_import, unused_import

import 'dart:ffi';

import 'package:aqlite/model/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/container.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshData() async {
    final data = await SQLHelper.getEmployee();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }
  @override
  // ignore: must_call_super
  void initState() {
    _refreshData();
    // print("Number of Employees: ${_journals.length}");
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _numberController.text = existingJournal['number'];
      _ageController.text = existingJournal['age'];
      _addressController.text = existingJournal['address'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 0,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  //mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'Name'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                      controller: _numberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Number'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.,]+')),
                      ],
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Age',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _addressController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(hintText: 'Address'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (id == null) {
                          await _addEmployee();
                        }
                        if (id != null) {
                          await _updateEmployee(id);
                        }
                        _nameController.text = '';
                        _numberController.text = '';
                        _ageController.text = '';
                        _addressController.text = '';

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'),
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> _addEmployee() async {
    await SQLHelper.createEmployee(_nameController.text, _numberController.text,
        _ageController.text, _addressController.text);
    _refreshData();
  }

  Future<void> _updateEmployee(int id) async {
    await SQLHelper.updateEmployee(id, _nameController.text,
        _numberController.text, _ageController.text, _addressController.text);
    _refreshData();
  }

  void _deleteEmployee(int id) async {
    await SQLHelper.deleteEmployee(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a data!'),
    ));
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "SqLite Database",
            style: TextStyle(color: Colors.white60),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _journals.length,
                itemBuilder: ((context, index) => Card(
                      color: Colors.blueAccent,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Column(children: [
                          Text(_journals[index]['name']),
                          Text(_journals[index]['number']),
                          Text(_journals[index]['age']),
                          Text(_journals[index]['address']),
                        ]),
                        // title: Text(_journals[index]['name']),
                        // subtitle: Text(_journals[index]['address']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.amber,
                              ),
                              onPressed: () =>
                                  _showForm(_journals[index]['id']),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () =>
                                  _deleteEmployee(_journals[index]['id']),
                            ),
                          ]),
                        ),
                      ),
                    ))));
  }
}
