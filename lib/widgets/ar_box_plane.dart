import 'dart:io';

import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/store_data/ar_shared_prefs.dart';
import 'package:ar_flutter_plugin/widgets/saved_dimensions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/datatypes/hittest_result_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as v;
import 'dart:math';

class ObjectsOnPlanesWidget extends StatefulWidget {
  ObjectsOnPlanesWidget({Key? key}) : super(key: key);
  @override
  _ObjectsOnPlanesWidgetState createState() => _ObjectsOnPlanesWidgetState();
}

class _ObjectsOnPlanesWidgetState extends State<ObjectsOnPlanesWidget> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;
  bool isTapped = false;

  late ARNode fileSystemNode;
  late HttpClient httpClient;

  //slider values
  double widthVal = 2;
  double heightVal = 2;
  double lengthVal = 2;

  v.Vector3 scale = v.Vector3(0.1, 0.1, 0.1);
  late v.Vector3 position;
  v.Vector4 rotation = v.Vector4(1.0, 0.0, 0.0, 0.0);
  late v.Matrix3 r;
  // List<ARNode> nodes = [];
  // List<ARAnchor> anchors = [];
  late ARNode node;
  late ARPlaneAnchor anchor;
  late var singleHitTestResult;

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
        msg: "Touch anywhere to put the box",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      ),
      Align(
        alignment: FractionalOffset.topRight,
        child: SizedBox(
          width: 230.0,
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(
              children: [
                Text(
                  'L: ',
                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.green[700],
                    inactiveTrackColor: Colors.green[100],
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbColor: Colors.greenAccent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayColor: Colors.green.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    min: 0.1,
                    max: 10,
                    value: lengthVal,
                    onChanged: isTapped
                        ? (value) {
                            setState(() {
                              lengthVal = value;
                              setScale();
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                Text(
                  'W: ',
                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.green[700],
                    inactiveTrackColor: Colors.green[100],
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbColor: Colors.greenAccent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayColor: Colors.green.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    min: 0.1,
                    max: 10,
                    value: widthVal,
                    onChanged: isTapped
                        ? (value) {
                            setState(() {
                              widthVal = value;
                              setScale();
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            Row(
              children: [
                Text(
                  'H: ',
                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.green[700],
                    inactiveTrackColor: Colors.green[100],
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4.0,
                    thumbColor: Colors.greenAccent,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                    overlayColor: Colors.green.withAlpha(32),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
                  ),
                  child: Slider(
                    min: 0.1,
                    max: 10,
                    value: heightVal,
                    onChanged: isTapped
                        ? (value) {
                            setState(() {
                              heightVal = value;
                              setScale();
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            SizedBox(
              width: 150.0,
              height: 50.0,
              child: Card(
                elevation: 5.0,
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Center(
                    child: Text(
                      'Length: ${(scale[0] * lengthVal * 100).toStringAsFixed(1)} cm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150.0,
              height: 50.0,
              child: Card(
                elevation: 5.0,
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Center(
                    child: Text(
                      'Width: ${(scale[2] * widthVal * 100).toStringAsFixed(1)} cm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 150.0,
              height: 50.0,
              child: Card(
                elevation: 5.0,
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Center(
                    child: Text(
                      'Height: ${(scale[1] * heightVal * 100).toStringAsFixed(1)} cm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
      Align(
        alignment: FractionalOffset.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // This is what you need!
            ),
            onPressed: () {
              setState(() {
                List<String> lList = [];
                List<String> wList = [];
                List<String> hList = [];

                ArSharedPrefs.getDimension('length').then((value) {
                  lList = value ?? [];
                });
                ArSharedPrefs.getDimension('width').then((value) {
                  wList = value ?? [];
                });
                ArSharedPrefs.getDimension('height').then((value) {
                  hList = value ?? [];
                });

                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedDimensions(lList: lList, wList: wList, hList: hList)));
              });
            },
            child: Icon(Icons.access_time),
          ),
        ),
      ),
      Align(
        alignment: FractionalOffset.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.green, // This is what you need!
            ),
            onPressed: () {
              String l = (scale[0] * lengthVal * 100).toStringAsFixed(1);
              String w = (scale[2] * widthVal * 100).toStringAsFixed(1);
              String h = (scale[1] * heightVal * 100).toStringAsFixed(1);
              setState(() {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.SUCCES,
                  animType: AnimType.BOTTOMSLIDE,
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save dimensions?',
                        style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Length: ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$l cm',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Width: ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$w cm',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Height: ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$h cm',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.0),
                    ],
                  ),
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    saveDimensions(l, w, h);
                  },
                )..show();
              });
            },
            child: Text("Save"),
          ),
        ),
      ),
    ]));
  }

  //Save dimensions on local storage
  void saveDimensions(String l, String w, String h) {
    List<String> lList = [];
    List<String> wList = [];
    List<String> hList = [];

    ArSharedPrefs.getDimension('length').then((value) {
      lList.addAll(value!);
    });
    ArSharedPrefs.getDimension('width').then((value) {
      wList.addAll(value!);
    });
    ArSharedPrefs.getDimension('height').then((value) {
      hList.addAll(value!);
    });

    lList.add(l);
    wList.add(w);
    hList.add(h);

    ArSharedPrefs.setLength(lList);
    ArSharedPrefs.setWidth(wList);
    ArSharedPrefs.setHeight(hList);
  }

  //, ARLocationManager arLocationManager
  void onARViewCreated(ARSessionManager arSessionManager, ARObjectManager arObjectManager, ARAnchorManager arAnchorManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    this.arSessionManager.onInitialize(
          showFeaturePoints: false,
          showPlanes: true,
          // customPlaneTexturePath: widget.asset,
          showWorldOrigin: false,
        );

    // Download model to file system
    httpClient = new HttpClient();
    ArSharedPrefs.getFileDownloaded().then((val){
      if(!val){
        _downloadFile("https://github.com/YeLwinOo-Steve/transparentbox/raw/main/box.glb", "box.glb").then((data) => {});
        ArSharedPrefs.setFileDownloaded();
      }
    });
    this.arObjectManager.onInitialize();
    this.arSessionManager.onPlaneOrPointTap = onPlaneOrPointTapped;
    this.arObjectManager.onNodeTap = onNodeTapped;
  }

  Future<File> _downloadFile(String url, String filename) async {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    print("        Downloading finished, path: " + '$dir/$filename');
    return file;
  }

  Future<void> onRemoveEverything() async {
    /*nodes.forEach((node) {
      this.arObjectManager.removeNode(node);
    });*/
    // anchors.forEach((anchor) {
    //   isTapped = false;
    this.arAnchorManager.removeAnchor(anchor);
    // });
    // anchors = [];
  }

  Future<void> onNodeTapped(List<ARHitTestResult> hits) async {
    // var number = nodes.length;
    //
    // for (int i = 0; i < number; i++) {
    //   print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + nodes[i].toString());
    // }
    // node.transform.setDiagonal(v.Vector4(scale[0] * lengthVal, scale[1] * heightVal, scale[2] * widthVal, 1));
    // this.arObjectManager.updateNode(node);

    var hitTest = hits[hits.length-1];
    var p = v.Vector3(
      hitTest.worldTransform.getColumn(3).x,
      hitTest.worldTransform.getColumn(3).y,
      hitTest.worldTransform.getColumn(3).z,
    );
    node.position = p;
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + p.toString());

    // var hitTest = hits.firstWhere(
    //         (hitTestResult) => hitTestResult.type == ARHitTestResultType.point);
    // var p = v.Vector3(
    //   singleHitTestResult.worldTransform.getColumn(3).x,
    //   singleHitTestResult.worldTransform.getColumn(3).y,
    //   singleHitTestResult.worldTransform.getColumn(3).z,
    // );
  }

  Future<void> onPlaneOrPointTapped(List<ARHitTestResult> hitTestResults) async {
    if (!isTapped) {
      singleHitTestResult = hitTestResults.firstWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      this.anchor = ARPlaneAnchor(transformation: singleHitTestResult.worldTransform);
      bool? didAddAnchor = await this.arAnchorManager.addAnchor(this.anchor);

      if (didAddAnchor != null && didAddAnchor) {
        // this.anchors.add(newAnchor);
        // Add node to anchor
        position = v.Vector3(
          singleHitTestResult.worldTransform.getColumn(3).x,
          singleHitTestResult.worldTransform.getColumn(3).y,
          singleHitTestResult.worldTransform.getColumn(3).z,
        );
        node = ARNode(
            type: NodeType.fileSystemAppFolderGLB,
            uri: "box.glb",
            rotation: rotation,
            position: position,
            transformation: singleHitTestResult.worldTransform);
        node.transform.setDiagonal(v.Vector4(scale[0] * lengthVal, scale[1] * heightVal, scale[2] * widthVal, 1));

        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" + node.position.toString());

        bool? didAddNodeToAnchor = await this.arObjectManager.addNode(node, planeAnchor: anchor);
        this.arObjectManager.updateNode(node, planeAnchor: anchor);
        if (didAddNodeToAnchor != null && didAddNodeToAnchor) {
          // this.nodes.add(newNode);
          setState(() {
            isTapped = true;
          });
        } else {
          this.arSessionManager.onError("Adding Node to Anchor failed");
        }
      } else {
        this.arSessionManager.onError("Adding Anchor failed");
      }
    } else {
      var hitTest = hitTestResults.lastWhere((hitTestResult) => hitTestResult.type == ARHitTestResultType.plane);
      var p = v.Vector3(
        hitTest.worldTransform.getColumn(3).x,
        hitTest.worldTransform.getColumn(3).y,
        hitTest.worldTransform.getColumn(3).z,
      );

      node.transform.setTranslation(p);
      this.arObjectManager.updateNode(node);
      print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<" + p.toString());
    }
  }

  void setScale() async {
    node.transform.setDiagonal(v.Vector4(scale[0] * lengthVal, scale[1] * heightVal, scale[2] * widthVal, 1));
    this.arObjectManager.updateNode(node);
    print("================================================================= ");
    print(node.transform.toString());
    print("================================================================= ");
  }
}
