import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer' as dev;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'water calorie',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'water calorie keygen'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var money = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: "money",
                ),
                controller: money,
              ),
            ),
            const SizedBox(height: 20,),

            ElevatedButton(
                child: const Text("Press close to the card"),
                onPressed: () async {
                  await writeDataToMifareClassic();
                }),
          ],
        ),
      ),
    );
  }

  toast(s) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> writeDataToMifareClassic() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      dev.log("NFC is not supported");
      toast("NFC is not supported");
    }
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (tag.data.isNotEmpty) {
        var mifareClassic = MifareClassic.from(tag);
        if (mifareClassic != null) {
          // Authenticate sector 10 with key A
          var authenticateSuccessful =
              await mifareClassic.authenticateSectorWithKeyB(
                  sectorIndex: 10,
                  key:
                      Uint8List.fromList([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]));
          if (authenticateSuccessful) {
            // Write data to block 0 of sector 10
            var m='${money.text}00';
            await mifareClassic.writeBlock(
                data: get_data(int.parse(m)),
                blockIndex: 10 * 4);
            toast("Data written successfully");
          } else {
            toast('Authentication failed');
          }
        } else {
          toast('error: not is mifare Classic');
        }
      } else {
        toast("data is empty");
      }
    });

    // NfcManager.instance.stopSession();
  }


  Uint8List get_data(int m){
    var hexM=_intToHex(m);
    var _3=int.parse('0x${hexM.substring(hexM.length-2,hexM.length)}');
    var _4=int.parse('0x${hexM.substring(0,hexM.length-2)}');

    var _6=0xff-_3-_4;
    var _2=~_6&0xff;
    var _8=8;
    var _15=0x8a;
    var h1=[_2,_3,_4,0,_6,0,_8,0,0,0,0,0,0xff,_15];
    var _16=~h1.reduce((a, b) => a+b) & 0xff;
    var _1=0;
    for (var e in h1) {_1^=e;}
    var h=[_1,_16];
    h.insertAll(1, h1);

    // var hex=h.map((e) => _intToHex(e)).toList().join(" ");
    return Uint8List.fromList(h);


  }

  String _intToHex(int num) {
    String hexString = num.toRadixString(16);
    return hexString.padLeft(4,'0');
  }
}
