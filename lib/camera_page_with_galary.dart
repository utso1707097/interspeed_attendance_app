import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:convert';

import 'controller/update_profile_controller.dart';

class CameraPageWithGallery extends StatefulWidget {
  final EmployeeUpdateController controller;
  CameraPageWithGallery({required this.controller});

  @override
  _CameraPageWithGalleryState createState() => _CameraPageWithGalleryState();
}

class _CameraPageWithGalleryState extends State<CameraPageWithGallery> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  late XFile _imageFile;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _imageFile = XFile(''); // Initialize with a default or null value
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      _isFrontCamera ? cameras[1] : cameras[0],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _cameraController.takePicture();

// Use image package to handle orientation
      final img.Image capturedImage = img.decodeImage(await File(image.path)
          .readAsBytes())!; // Use ! to assert non-nullability

// Check if the image needs to be mirrored based on camera sensor orientation
      bool mirrorImage = _cameraController.description?.sensorOrientation == 90;

// Apply orientation and mirror adjustments
      final img.Image orientedImage = img.copyRotate(capturedImage, angle: 180);
      img.flipVertical(orientedImage);
      if (mirrorImage) {
        // Mirror the image horizontally
        img.flipHorizontal(orientedImage);
      }

// Save the oriented image
      await File(image.path).writeAsBytes(img.encodeJpg(orientedImage));

// Update _imageFile to point to the same file
      setState(() {
        _imageFile = XFile(image.path);
      });
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = XFile(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // ... (rest of the code remains the same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_cameraController.value.isInitialized) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CameraPreview(_cameraController),
                    if (_imageFile != null && _imageFile.path.isNotEmpty)
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
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
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 36.0,
                              ),
                              onPressed: () async {
                                List<int> imageBytes = await File(_imageFile.path).readAsBytes();
                                String base64Image = base64Encode(imageBytes);
                                print(base64Image);
                                print('Image confirmed!');
                                Navigator.pop(context, base64Image);
                                widget.controller.setImagePath(_imageFile.path);
                                setState(() {
                                  _imageFile = XFile('');
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                // Change the color to light green
                                size:
                                36.0, // Change the size to 36.0 or any other desired size
                              ),
                              onPressed: () {
                                print('Image discarded!');
                                //Navigator.of(context).pop(); // Close the dialog
                                setState(() {
                                  _imageFile = XFile('');
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text("Camera not initialized"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xff1a1a1a),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.photo, color: Colors.white),
              onPressed: _pickImageFromGallery,
            ),
            IconButton(
              icon: const Icon(
                Icons.camera,
                color: Colors.white,
              ),
              onPressed: _takePicture,
            ),
            IconButton(
              icon: const Icon(Icons.switch_camera, color: Colors.white),
              onPressed: _toggleCamera,
            ),
          ],
        ),
      ),
    );
  }
}
