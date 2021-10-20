import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Type definitions to enforce a consistent use of the API
typedef NodeTapResultHandler = void Function(List<String> nodes);

typedef AnchorEventHandler = void Function(ARPlaneAnchor anchor);

/// Manages the all node-related actions of an [ARView]
class ARObjectManager extends ChangeNotifier{
  /// Platform channel used for communication from and to [ARObjectManager]
  late MethodChannel _channel;

  /// Debugging status flag. If true, all platform calls are printed. Defaults to false.
  final bool debug;

  /// Callback function that is invoked when the platform detects a tap on a node
  NodeTapResultHandler? onNodeTap;

  /// Called when a node will be updated with data from the given anchor.
  AnchorEventHandler? onUpdateNodeForAnchor;

  /// Called when a mapped node has been removed from the scene graph for the given anchor.
  AnchorEventHandler? onDidRemoveNodeForAnchor;

  ARObjectManager(int id, {this.debug = false}) {
    _channel = MethodChannel('arobjects_$id');
    _channel.setMethodCallHandler(_platformCallHandler);
    if (debug) {
      print("ARObjectManager initialized");
    }
  }

  Future<void> _platformCallHandler(MethodCall call) {
    if (debug) {
      print('_platformCallHandler call ${call.method} ${call.arguments}');
    }
    try {
      switch (call.method) {
        case 'onError':
          print(call.arguments);
          break;
        case 'onNodeTap':
          if (onNodeTap != null) {
            final tappedNodes = call.arguments as List<dynamic>;
            onNodeTap!(tappedNodes
                .map((tappedNode) => tappedNode.toString())
                .toList());

            // final rawHitTestResults = call.arguments as List<dynamic>;
            // final serializedHitTestResults = rawHitTestResults
            //     .map(
            //         (hitTestResult) => Map<String, dynamic>.from(hitTestResult))
            //     .toList();
            // final hitTestResults = serializedHitTestResults.map((e) {
            //   return ARHitTestResult.fromJson(e);
            // }).toList();
            // onNodeTap!(hitTestResults);
          }
          break;
        case 'onUpdateNodeForAnchor':
          print("Anchor ==============================================> ${call.arguments}");
          if (onUpdateNodeForAnchor != null) {
            final anchor =
            ARPlaneAnchor.fromJson(Map<String, dynamic>.from(call.arguments));
            onUpdateNodeForAnchor!(anchor);
          }
          break;
        case 'didRemoveNodeForAnchor':
          if (onDidRemoveNodeForAnchor != null) {
            final anchor =
            ARPlaneAnchor.fromJson(Map<String, dynamic>.from(call.arguments));
            onDidRemoveNodeForAnchor!(anchor);
          }
          break;
        default:
          if (debug) {
            print('Unimplemented method ${call.method} ');
          }
      }
    } catch (e) {
      print('Error caught: ' + e.toString());
    }
    return Future.value();
  }

  /// Sets up the AR Object Manager
  onInitialize() {
    _channel.invokeMethod<void>('init', {});
  }

  /// Add given node to the given anchor of the underlying AR scene (or to its top-level if no anchor is given) and listen to any changes made to its transformation
  Future<bool?> addNode(ARNode node, {ARPlaneAnchor? planeAnchor}) async {
    try {
      node.transformNotifier.addListener(() {
        _channel.invokeMethod<void>('transformationChanged', {
          'name': node.name,
          'transformation':
              MatrixValueNotifierConverter().toJson(node.transformNotifier)
        });
      });
      if (planeAnchor != null) {
        if(planeAnchor.childNode != ''){

          planeAnchor.childNode = '';
        }
        planeAnchor.childNode = node.name;
        return await _channel.invokeMethod<bool>('addNodeToPlaneAnchor',
            {'node': node.toMap(), 'anchor': planeAnchor.toJson()});
      } else {
        return await _channel.invokeMethod<bool>('addNode', node.toMap());
      }
    } on PlatformException catch (e) {
      return false;
    }
  }

  Future<void> updateNode(ARNode node, {ARPlaneAnchor? planeAnchor} ) async{
    print(node.transformNotifier.hasListeners);
    node.transformNotifier.notifyListeners();
  }

  Future<void> removeNode(ARNode node) async{
    _channel.invokeMethod<void>('removeNode', {
      'name': node.name
    });
    // node.transformNotifier.value = node.transform;
    // _channel.invokeMethod<void>('transformationChanged', {
    //   'name': node.name,
    //   'transformation':
    //   MatrixValueNotifierConverter().toJson(node.transformNotifier)
    // });
  }

}
