import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileManagement {
  static pickImage() async {
    PickedFile image = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      return File(image.path);
    } else {
      return null;
    }
  }

  static pickFiles() async {
    List<File> files = [];
    FilePickerResult results;
    try {
      results = await FilePicker.platform.pickFiles(allowMultiple: true);
    } on Exception catch (e) {}
    if (results != null) {
      for (String path in results.paths) {
        files.add(File(path));
      }
      return files;
    } else {
      return null;
    }
  }

  static getImage() {}

/*
  static uploadFiles(List files, fileName) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();

    for (File file in files) {

    String fileName =
          '${widget.subTopic}_${(bookNameList[0] == 'No Books' ? 0 : bookNameList.length).toString()}';

      String filePath = '${appDocDir.path}/$fileName';
      File pickedFile = File(filePath);
      var bytes = await _readFileByte(file.path, 'path');
      pickedFile.writeAsBytesSync(bytes);

      bookNameList[0] == 'No Books'
          ? bookNameList = []
          : bookNameList = bookNameList;
      bookNameList.add(fileName);
      selectBook = bookNameList[0];
    }
  }
*/
}
