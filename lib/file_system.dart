import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileSystem {
  String? _currentFilePath;
  String? _currentFileName;

  //Function to save file
  Future<void> saveFile(String content, {String? fileName}) async {
    if (_currentFilePath == null || fileName == null) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        print("No directory selected.");
        return;
      }
      _currentFilePath = '$selectedDirectory/$fileName';
      _currentFileName = fileName;
    }
    File file = File(_currentFilePath!);
    await file.writeAsString(content);
    print("File saved successfully at $_currentFilePath");
  }

  //Function to read a file
  Future<String> readFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final pickedFile = result.files.first;
      _currentFilePath = pickedFile.path;
      _currentFileName = pickedFile.name;
      File file = File(_currentFilePath!);
      String fileContent = await file.readAsString();
      return fileContent;
    } else {
      return "No file selected or read error.";
    }
  }

  Future<String?> filenameContainer() async {
    return _currentFileName;
  }
}