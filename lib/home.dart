import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'file_system.dart';

const String endpoint = 'https://api.jdoodle.com/v1/execute';
const String clientId = '124d2895aa080c42166111ff50151882';
const String clientSecret = '65c5f608cea02af5c955535bf9004dc5ca8880d24d7daf009f993a2b2607f752';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    setEditorContent(initialText);
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
        //Slide menu
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                ),
                child: Text('Hello There!'),
              ),
              ListTile(
                leading: Icon(
                  Icons.file_copy,
                ),
                title: const Text('Save File'),
                onTap: () async {
                  String content = controller.document.toPlainText();
                  String? fileName = await FileSystem().filenameContainer();

                  if (fileName == null || fileName.isEmpty) {
                    fileName = await showFileNameDialog(context);
                    if (fileName != null && fileName.isNotEmpty) {
                      await FileSystem().saveFile(content, fileName: fileName);
                    }
                  } else {
                    await FileSystem().saveFile(content);
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.file_open,
                ),
                title: const Text('Open File'),
                onTap: () async {
                  String fileContent = await FileSystem().readFile();
                  setEditorContent(fileContent);
                },
              ),
            ],
          ),
        ),
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
            //Divider between code-writing field and result field
            Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_output, style: TextStyle(fontFamily: 'monospace')),
              ),
            ),
            //Customized buttons for the quick typing
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
  //Update content in the editor
  void setEditorContent(String newContent) {
    // Create a new document with the new content
    final document = quill.Document()..insert(0, newContent);

    // Update the controller with the new document
    controller = quill.QuillController(
        document: document,
        selection: TextSelection.collapsed(offset: 0) // Place cursor at the start of the document
    );

    setState(() {});
  }
  //Dialog that pops out when user clicks 'Save File'
  Future<String?> showFileNameDialog(BuildContext context) async {
    TextEditingController fileNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: "Type filename"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(fileNameController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
