import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ValueNotifier<dynamic> result = ValueNotifier(null);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('NfcManager Plugin Example')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(border: Border.all()),
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<dynamic>(
                        valueListenable: result,
                        builder: (context, value, _) =>
                            Text('${value ?? ''}'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(

                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple
                          ),
                            child: Text('Tag Read'), onPressed:() =>  _tagRead(context)),
                       
                       

                        ElevatedButton(
                            child: const Text("Text 'somthing text abc...' Write"),
                            onPressed:() =>  _ndefWriteText(context)),
                        
                         ElevatedButton(
                            child: const Text("Link Write"),
                            onPressed:() =>  _ndefWriteLink(context)),
                             ElevatedButton(
                            child: const Text("Contact info Write"),
                            onPressed:() =>  _ndefWriteContact(context)),
                        ElevatedButton(
                            child: const Text('Application Launch Write'),
                            onPressed:() =>  _ndefWrite(context)),

                      ],
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //en is language = "en"

  void _tagRead(context) {
    try{
      NfcManager.instance.stopSession();
    }catch(e){
    }
    dialogContent(context);
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        print("Starting reading session");
        Navigator.pop(context);
        try {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            NdefMessage message = await ndef.read(); // Read NDEF message
          if(message != null){

            result.value = "";
            for (var data in message.records){
              String payload = String.fromCharCodes(data.payload);
              if(payload.contains("en")){
                payload.replaceFirst("en", "");
              }
              result.value += payload + "\n";
            }

          }
          } else {
            result.value = 'Tag is not NDEF compatible';
          }
        } catch (e) {
          result.value = 'Error reading NDEF data: $e';
        } finally {
          Future.delayed(Duration(seconds: 1),() => NfcManager.instance.stopSession(),);
        }
      },
    );
  }




  // add link 
  void _ndefWriteLink(context) {
    try{
      NfcManager.instance.stopSession();
    }catch(e){

    }
    dialogContent(context);
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Navigator.pop(context);
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      NdefMessage message = NdefMessage([
        NdefRecord.createUri(Uri.parse('https://www.google.com/m')),

      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';


        Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);

      } catch (e) {
        result.value = e;
       Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);
        return;
      }
    });
  }


  void _ndefWriteContact(context) {
  try {
    // Stop the current NFC session if there's one
    NfcManager.instance.stopSession();
  } catch (e) {
    // Handle any errors if stopping the session fails
  }

  // Display a dialog
  dialogContent(context);

  // Define contact details (replace with your own contact information)
  String contactName = "John Doe";
  String contactPhoneNumber = "+1234567890";
  String contactEmail = "johndoe@example.com";

  // Create a vCard (VCF) string with the contact details
  String vCardData = "BEGIN:VCARD\n"
      "VERSION:3.0\n"
      "FN:$contactName\n"
      "TEL:$contactPhoneNumber\n"
      "EMAIL:$contactEmail\n"
      "END:VCARD";

  // Convert the vCard data to bytes
  List<int> vCardBytes = utf8.encode(vCardData);

  // Start an NFC session
  NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    Navigator.pop(context); // Close the dialog

    var ndef = Ndef.from(tag);

    // Check if the NFC tag is writable
    if (ndef == null || !ndef.isWritable) {
      result.value = 'Tag is not NDEF writable';
      NfcManager.instance.stopSession(errorMessage: result.value);
      return;
    }

    // Create an NDEF record with a custom MIME type (vCard) and the contact information
    NdefRecord mimeRecord = NdefRecord.createMime(
      'text/vcard', // MIME type for vCard

      Uint8List.fromList(vCardData.codeUnits),
    );

    // Create an NDEF message containing the vCard record
    NdefMessage message = NdefMessage([mimeRecord]);

    try {
      // Write the NDEF message to the tag
      await ndef.write(message);
      result.value = 'Success to "NDEF Write"';

      // Delayed session stop to allow time to see the result
      Future.delayed(Duration(seconds: 1), () {
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
      });
    } catch (e) {
      result.value = e;

      // Delayed session stop in case of an error
      Future.delayed(Duration(seconds: 1), () {
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
      });
    }
  });
}





  void _ndefWrite(context) {
    try{
      NfcManager.instance.stopSession();
    }catch(e){

    }
    dialogContent(context);
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Navigator.pop(context);
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
      NdefMessage message = NdefMessage([
      //  NdefRecord.createText('Zetro Malik'),
        //NdefRecord.createText('App Store:'),
        //NdefRecord.createUri(Uri.parse('https://tapni.com')),

        NdefRecord.createExternal('android.com', 'pkg', Uint8List.fromList('com.example.nfc_app'.codeUnits)),
       // NdefRecord.createUri(Uri.parse('android-app:com.example.nfc_app')),
        // NdefRecord.createText('Website'),
        //
        // NdefRecord.createMime(
        //     'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        // NdefRecord.createExternal(
        //     'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';


        Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);

      } catch (e) {
        result.value = e;
       Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);
        return;
      }
    });
  }




void _ndefWriteText(context) {
    try{
      NfcManager.instance.stopSession();
    }catch(e){

    }
    dialogContent(context);
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        Navigator.pop(context);
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      // To add some kind of text
      NdefMessage message = NdefMessage([
       NdefRecord.createText('some text abc...'),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';


        Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);

      } catch (e) {
        result.value = e;
       Future.delayed(Duration(seconds: 1),() =>  NfcManager.instance.stopSession(errorMessage: result.value.toString()),);
        return;
      }
    });
  }



    dialogContent(BuildContext context) {
     showDialog(
            context: context,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
      width: 260,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.network(
            'https://assets-v2.lottiefiles.com/a/a68e4064-1166-11ee-a842-97da89eaf7c1/pRpPDA70yq.gif', // NFC GIF URL
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'Bring the NFC Tag closer to your phone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
         
        ],
      ),
    ),
            ),
          );
  }


}


