import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

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

  // preProcessImage(File image) {
  //   ImageProcessor imageProcessor = ImageProcessorBuilder()
  //       .add(ResizeOp(224, 224, ResizeMethod.NEAREST_NEIGHBOUR))
  //       .build();
  //   TensorImage tensorImage = TensorImage.fromFile(image);
  //   tensorImage = imageProcessor.process(tensorImage);
  //   File file = File().

  // }

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.send),
        onPressed: pickImage,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _loading
              ? Container(
                  height: 300,
                  width: 300,
                )
              : Container(
                  margin: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _image == null ? Container() : Image.file(_image),
                      SizedBox(
                        height: 20,
                      ),
                      _image == null
                          ? Container()
                          : _outputs != null
                              ? Text(
                                  '${(_outputs[0]['confidence'] * 100).toInt()}% => ${_outputs[0]["label"]}',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                )
                              : Container(child: Text(""))
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
