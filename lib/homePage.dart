import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  File _image;
  List _outputs;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: 'assets/mobilenet_v2_1.0_224.tflite',
        labels: 'assets/labels_mobilenet_quant_v1_224.txt',
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    print("OUTPUT : ");
    print(output);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  pickImage() async {
    var pickedImage = await _imagePicker.getImage(source: ImageSource.gallery);
    var image = File(pickedImage.path);
    if (image == null) return null;
    setState(() {
      _loading = false;
      _image = image;
    });
    try {
      classifyImage(_image);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          child: Icon(Icons.send),
          onPressed: pickImage,
        ),
        body: Container(
          alignment: Alignment(0, 0),
          child: _loading
              ? CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                )
              : Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child:
                              _image == null ? Container() : Image.file(_image),
                        ),
                      ),
                      Expanded(
                        child: _image == null
                            ? Container()
                            : _outputs != null
                                ? Center(
                                    child: Text(
                                      '${(_outputs[0]['confidence'] * 100).toInt()}% => ${_outputs[0]["label"]}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Container(),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
