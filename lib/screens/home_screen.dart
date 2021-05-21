import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:object_detection_app/main.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  CameraController cameraController;
  CameraImage imgCamera;
  bool isWorking = false;
  double imgHeight;
  double imgWidth;
  List recognitionList;


  void initCamera() {

    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {
      if(!mounted){
        return;
      }
      setState(() {
        cameraController.startImageStream((imageFromStream) {
          if(!isWorking){
            isWorking = true;
            imgCamera = imageFromStream;
            runModelOnStreamFrame();
          }
        });
      });
    });
  }

    runModelOnStreamFrame() async{
      imgHeight = imgCamera.height + 0.0;
      imgWidth = imgCamera.width + 0.0;
      recognitionList = await Tflite.detectObjectOnFrame(
        bytesList: imgCamera.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        model: "SSDMobileNet",
        imageHeight: imgCamera.height,
        imageWidth: imgCamera.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 1,
        threshold: 0.4,

      );
    isWorking = false;
    setState(() {
      imgCamera;
    });
  }

  Future loadModel() async{
    Tflite.close();
    try{
      String response;
     response =  await Tflite.loadModel(model: "assets/ssd_mobilenet.tflite", labels: "assets/ssd_mobilenet.txt");
      print(response);
    }
    on PlatformException{
      print("Unable to load model");
    }
  }

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.stopImageStream();
    Tflite.close();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera();
    loadModel();
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen){
    if(recognitionList == null) return [];

    if(imgHeight == null || imgWidth == null) return [];

    double factorX = screen.width;
    double factorY = imgHeight;

    Color colorPick = Colors.orange;

    return recognitionList.map((result){
      return Positioned(
        left: result["rect"]["x"] * factorX,
        top: result["rect"]["y"] * factorY,
        width: result["rect"]["w"] * factorX,
        height: result["rect"]["h"] * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: colorPick,width: 2.0),
          ),
          child: Text("${result['detectedClass']} ${(result['confidenceInClass'] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = colorPick,
            color: Colors.black,
            fontSize: 16.0,

          ),),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildrenWidgets = [];
    stackChildrenWidgets.add(
      Positioned(
        top: 0.0,
          left: 0.0,
          width: size.width,
          height: size.height - 100,
          child: Container(
            height:size.height - 100,
            child: (!cameraController.value.isInitialized) ?
            Container() :
            AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
              child: CameraPreview(cameraController),
            ),
          )
      )
    );

    if(imgCamera !=null){
      stackChildrenWidgets.addAll(displayBoxesAroundRecognizedObjects(size));
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 50),
            color: Colors.black,
            child: Stack(
              children: stackChildrenWidgets,
            ),
          ),
        ),
      ),
    );
  }
}
