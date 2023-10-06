import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

import 'detect_view.dart';
import 'object_detector_view.dart';
import 'utils.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: 
      const MyHomePage(title: 'Ml Image Labeling'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImageLabeler _imageLabeler;
  List<String> models = ["fruits_model", "lite-model_object_detection_mobile_object_localizer_v1_1_metadata_2", "lite-model_on_device_vision_classifier_landmarks_classifier_europe_V1_1",
   "mnasnet_1.3_224_1_metadata_1", "mobilenet_v1_1.0_224_1_metadata_1", "model", "utility_model", "object_labeler", "object_labeler_fruits"];
  String mpath = "mnasnet_1.3_224_1_metadata_1";
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final path = "asset/$mpath.tflite";
    final modelPath = await getAssetPath(path);
    final ImageLabelerOptions options = 
    LocalLabelerOptions(modelPath: modelPath); 
    // ImageLabelerOptions(confidenceThreshold: 0.5);
    _imageLabeler = ImageLabeler(options: options,);  
  }

  String text = '';
  int index = 0;
  double confidence = 0.0;


  List<ImageLabel> labeldetected = [];
  Future<void> processImage (InputImage inputImage) async {
    final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);
    log(labels.toString());
    labeldetected = labels;
    for (ImageLabel label in labels) {
      text = label.label;
      index = label.index;
      confidence = label.confidence;
    }
    setState(() {
      
    });
  }

  String pickedImage = '';
  pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(picked != null){
      setState(() {
        pickedImage = picked.path;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ImageLabelView(),));
            }, 
            icon: const Icon(Icons.camera) 
          ),
          IconButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ObjectDetectorView(),));
            }, 
            icon: const Icon(Icons.offline_bolt) 
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15.0),
                child: DropdownButton<String>(
                  value: mpath,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      mpath = value!;
                      initialize();
                    });

                  },
                  items: models.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              // SizedBox(
              //   height: 50,
              //   child: DropdownButton(
              //     value: mpath,
              //     items: models.map((e) => DropdownMenuItem(value: e,child: Text(e), )).toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         mpath = value.toString();
              //       });
              //     },
              //   ),
              // ),
              pickedImage != ""
                ? Image.file(File(pickedImage), height: 200,)
                : Container(),  
              TextButton(
                onPressed: (){
                  pickImage();
                }, 
                child: const Text("Add Image")
              ),
      
              MaterialButton(
                color: Colors.blue,
                onPressed: (){
                  processImage(InputImage.fromFilePath(pickedImage));
                }, 
                child: const Text("Process")
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: labeldetected.length,
                itemBuilder: (context, index) => 
                  Card(
                    child: ListTile(
                      title: Text(labeldetected[index].label),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Index: ${labeldetected[index].index}"),
                          Text("Confidence: ${labeldetected[index].confidence}"),
                        ],
                      ),
                    ),
                  ), 
              )
            ],
          ),
        ),
      ),
    );
  }
}
