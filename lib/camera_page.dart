import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late XFile _imageFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _imageFile = XFile(''); // Initialize with a default or null value
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _cameraController.takePicture();

      // If you want to display the captured image immediately:
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }


  Future<void> saveImageToLocalDirectory(String imagePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDirPath = path.join(appDir.path, 'static');

      // Create 'images' directory if it doesn't exist
      if (!Directory(imagesDirPath).existsSync()) {
        Directory(imagesDirPath).createSync();
      }

      // Get the original file name from the path
      final String originalFileName = path.basename(imagePath);

      // Create the destination path in the 'images' directory
      final String localImagePath = path.join(imagesDirPath, originalFileName);

      // Copy the image file to the 'images' directory
      File(imagePath).copySync(localImagePath);

      // Now, localImagePath contains the path to the saved image in local storage
      print('Image saved to local storage: $localImagePath');
    } catch (e) {
      print('Error saving image to local storage: $e');
    }
  }



  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_cameraController.value.isInitialized) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CameraPreview(_cameraController),
                  if (_imageFile != null)
                    Positioned(
                      top: 10.0,
                      right: 10.0,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FileImage(File(_imageFile.path)),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.check),
                                        onPressed: () async{
                                          // Handle the logic when the tick button is pressed
                                          // For now, print a message and reset _imageFile
                                          await saveImageToLocalDirectory(_imageFile.path);
                                          print('Image confirmed!');
                                          Navigator.of(context).pop(); // Close the dialog
                                          setState(() {
                                            _imageFile = XFile('');
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          // Handle the logic when the cross button is pressed
                                          // For now, print a message and reset _imageFile
                                          print('Image canceled!');
                                          Navigator.of(context).pop(); // Close the dialog
                                          setState(() {
                                            _imageFile = XFile('');
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(_imageFile.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _takePicture,
                      child: Icon(Icons.camera),
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text("Camera not initialized"));
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
