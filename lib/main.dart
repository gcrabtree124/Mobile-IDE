import 'package:flutter/material.dart';

import 'home.dart';

const String endpoint = 'https://api.jdoodle.com/v1/execute';
const String clientId = '124d2895aa080c42166111ff50151882';
const String clientSecret = '65c5f608cea02af5c955535bf9004dc5ca8880d24d7daf009f993a2b2607f752';


void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    //final quill.QuillController controller = quill.QuillController.basic();
    //final QuillEditorConfigurations quillConfiguration = QuillEditorConfigurations();

    return MaterialApp(

      home:Home()

    );
  }
}