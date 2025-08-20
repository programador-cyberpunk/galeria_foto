import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  bool _inProcess = false;

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _inProcess = true;
    });

    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: source);

      if (pickedFile == null) {
        setState(() {
          _inProcess = false;
        });
        return;
      }

      final cropper = ImageCropper();
      final croppedFile = await cropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Imagem',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recortar Imagem',
            doneButtonTitle: 'Concluir',
            cancelButtonTitle: 'Cancelar',
          ),
        ],
      );

      setState(() {
        if (croppedFile != null) {
          _selectedImage = File(croppedFile.path);
        }
      });
    } finally {
      setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera e Galeria'),
      ),
      body: _inProcess
          ? Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.grey.shade300,
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(125),
              child: Image.file(
                _selectedImage!,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(125),
              ),
              child: Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text('Câmera'),
                  onPressed: () {
                    _getImage(ImageSource.camera);
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                  onPressed: () {
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}