import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'RHCP', votes: 2),
    // Band(id: '3', name: 'Sonata Artica', votes: 1),
    // Band(id: '4', name: 'Muse', votes: 3),
  ];

  @override
  void initState() {
    // TODO: implement initState

    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic data) {
    this.bands = (data as List).map((e) => Band.fromJson(e)).toList();
    setState(() {});
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   // In case we destroy the Home Page
  //   super.dispose();
  //   final socketService = Provider.of<SocketService>(context, listen: false);
  //   socketService.socket.off('active bands');
  // }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand),
      appBar: AppBar(
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.Online
                  ? Icon(Icons.check_circle, color: Colors.blue)
                  : socketService.serverStatus == ServerStatus.Offline
                      ? Icon(Icons.offline_bolt, color: Colors.red)
                      : Icon(Icons.check_circle, color: Colors.yellow))
        ],
        elevation: 1,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _showGraph(),
            Expanded(
                child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => bandTile(bands[i]),
            )),
          ],
        ),
      ),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {"id": band.id})
      //TODO: llamar el borrado en el server
      ,
      background: Container(
        color: Colors.red,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete band', style: TextStyle(color: Colors.white))),
      ),
      child: ListTile(
        title: Text(band.name),
        onTap: () {
          print(band.id);
          socketService.socket.emit('vote-band', {'id': band.id});
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
        builder: (_) => AlertDialog(
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
        ),
      );
    } else if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
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
              ));
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      // this
      //     .bands
      //     .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {});
      socketService.socket.emit('add-band', {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((element) {
      dataMap.putIfAbsent(element.name, () => element.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[200],
      Colors.green[100],
      Colors.pink[100],
      Colors.red[100],
      Colors.red[80], 
      Colors.red[150],
      Colors.red[150],
      Colors.black,
    ];
    return dataMap.isEmpty
        ? Container()
        : Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            height: 200,
            child: PieChart(

              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              chartLegendSpacing: 25,
              colorList: colorList,
              initialAngleInDegree: 40,
              chartType: ChartType.ring,
              ringStrokeWidth: 20,
              // legendOptions: LegendOptions(

              //   showLegendsInRow: false,
              //   legendPosition: LegendPosition.right,
              //   showLegends: true,
              //   legendShape: BoxShape.circle,
              //   legendTextStyle: TextStyle(
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // chartValuesOptions: ChartValuesOptions(
              //   showChartValueBackground: true,
              //   showChartValues: true,
              //   showChartValuesInPercentage: false,
              //   // showChartValuesOutside: false,
              // ),
            ));
  }
}
