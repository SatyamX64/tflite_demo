import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
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

  pickImage(int val) async {
    var pickedImage = await _imagePicker.getImage(
        source: val == 1 ? ImageSource.camera : ImageSource.gallery);
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
        floatingActionButton: BoomMenu(
            animatedIcon: AnimatedIcons.menu_close,
            animatedIconTheme: IconThemeData(size: 22.0),
            overlayColor: Colors.black,
            overlayOpacity: 0.7,
            animationSpeed: 0,
            children: [
              MenuItem(
                child: Icon(Icons.camera, color: Colors.white),
                title: "Camera",
                titleColor: Colors.white,
                subtitle: "Click Image from Camera",
                subTitleColor: Colors.white,
                backgroundColor: Colors.blue,
                onTap: () => pickImage(1),
              ),
              MenuItem(
                child: Icon(Icons.image, color: Colors.white),
                title: "Gallery",
                titleColor: Colors.white,
                subtitle: "Pick Image from Gallery",
                subTitleColor: Colors.white,
                backgroundColor: Colors.blue,
                onTap: () => pickImage(2),
              ),
            ]),
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
                          child: _image == null
                              ? Align(
                                  alignment: Alignment(0, 0.6),
                                  child: Text(
                                    'Please Select an Image',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ))
                              : Image.file(_image),
                        ),
                      ),
                      Expanded(
                        child: _image == null
                            ? Container()
                            : _outputs != null
                                ? Align(
                                    alignment: Alignment(0, -0.4),
                                    child: Text(
                                      '${_outputs[0]["label"].toUpperCase()} (${(_outputs[0]['confidence'] * 100).toInt()} %)',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
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
