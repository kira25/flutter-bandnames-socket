import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'RHCP', votes: 2),
    Band(id: '3', name: 'Sonata Artica', votes: 1),
    Band(id: '4', name: 'Muse', votes: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand),
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => bandTile(bands[i]),
      ),
    );
  }

  Widget bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print("Direction : $direction");
        print("Direction : ${band.id}");
        //TODO: llamar el borrado en el server
      },
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete band', style: TextStyle(color: Colors.white))),
      ),
      child: ListTile(
        title: Text(band.name),
        onTap: () {
          print(band.name);
        },
        trailing: Text("${band.votes}",
            style: TextStyle(
              fontSize: 20,
            )),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text('${band.name.substring(0, 2)}'),
        ),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      //Android
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                  elevation: 5,
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text))
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              title: Text('New band name'),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: [
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text)),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: Text('Dismiss'),
                    onPressed: () => Navigator.pop(context)),
              ],
            );
          });
    }
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
