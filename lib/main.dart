import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding

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
  late quill.QuillController controller;
  bool _isLoading = false;
  String _output = '';

  @override
  void initState() {
    super.initState();
    // Define the initial text with a Java code template
    final initialText = '''
    public class Main {
        public static void main(String[] args) {
            
        }
    }
    ''';

    // Create a document and insert the initial text
    final document = quill.Document()..insert(0, initialText);

    // Initialize the controller with the document
    controller = quill.QuillController(document: document, selection: TextSelection.collapsed(offset: 0));
  }

  void _insertText(String text) {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;
    controller.replaceText(index, length, text, null);
  }

  Future<void> _runCode() async {
    String code = controller.document.toPlainText();
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'script': code,
          'language': 'java',
          'versionIndex': '3',
          'clientId': clientId,
          'clientSecret': clientSecret
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _output = data['output'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _output = 'Failed to compile and run code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Field',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Java Mobile IDE')),
        body: Column(
          children: [
            Expanded(
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: controller,
                  readOnly: false,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
              ),
            ),


            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _runCode,
                child: Text('Run Code'),
              ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output, style: TextStyle(fontFamily: 'monospace')),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => _insertText("\t"), child: Text('Tab')),
                  ElevatedButton(onPressed: () => _insertText(";"), child: Text(';')),
                  ElevatedButton(onPressed: () => _insertText("//"), child: Text('//')),
                  ElevatedButton(onPressed: () => _insertText("{}"), child: Text('{}')),
                  ElevatedButton(onPressed: () => _insertText("()"), child: Text('()')),
                  ElevatedButton(onPressed: () => _insertText("if(){}"), child: Text('if')),
                  ElevatedButton(onPressed: () => _insertText("else if(){}"), child: Text('else if')),
                  ElevatedButton(onPressed: () => _insertText("else {}"), child: Text('else')),
                  ElevatedButton(onPressed: () => _insertText("while(){}"), child: Text('while')),
                  ElevatedButton(onPressed: () => _insertText("for(){}"), child: Text('for')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
