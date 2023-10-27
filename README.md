# NFC Manager Integration in Flutter

This Flutter project demonstrates how to integrate the NFC Manager package and handle NFC-related operations. You can use this project as a reference for adding NFC functionality to your Flutter app.

## Getting Started

To get started with NFC integration, follow these steps:

1. **Add the nfc_manager package to your `pubspec.yaml` file:**

   - Add the `nfc_manager` package to your `pubspec.yaml` file with the desired version.

2. **Request Permissions on Android and iOS:**

   - On Android, add the following permissions to your AndroidManifest.xml file:

     - `<uses-feature android:name="android.hardware.nfc" android:required="true" />`
     - `<uses-permission android:name="android.permission.NFC" />`

   - On iOS, add the following keys to your Info.plist file:

     - `<key>NFCReaderUsageDescription</key>`
       `<string>Allow access to Create Sticker</string>`

     - `<key>com.apple.developer.nfc.readersession.felica.systemcodes</key>`
       `<array>`
         `<string>8005</string>`
         `<string>8008</string>`
         `<string>0003</string>`
         `<string>fe00</string>`
         `<string>90b7</string>`
         `<string>927a</string>`
         `<string>86a7</string>`
       `</array>`

     - `<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>`
       `<array>`
         `<string>A0000002471001</string>`
         `<string>A000000003101001</string>`
         `<string>A000000003101002</string>`
         `<string>A0000000041010</string>`
         `<string>A0000000042010</string>`
         `<string>A0000000044010</string>`
         `<string>44464D46412E44466172653234313031</string>`
         `<string>D2760000850100</string>`
         `<string>D2760000850101</string>`
         `<string>00000000000000</string>`
       `</array>`

3. **Reading NFC Tags:**

   To read an NFC tag, you can convert it into an `Ndef` object and use `.read()` to retrieve the message. The message can have multiple records, so you can iterate over them to process the payload.

4. **Writing Text Data:**

   To write text data to an NFC tag, use `NdefRecord.createText()`. You can insert any text data you need.

5. **Writing a Link:**

   To write a link (URL) to an NFC tag, use `NdefRecord.createUri()`. You can specify the URL, such as a website, WhatsApp opener, or location opener.

6. **Launching an App:**

   To open an app using an NFC tag, use `NdefRecord.createExternal()`. Specify the domain, type, and data to open the app.

You can modify and integrate these code snippets into your Flutter project for NFC-related functionality.
