import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    if (_file != null) {
      return File(_file.path);
    }
    return null;
  }

  // Future<List<XFile?>> getMultipleImageFromGallery() async {
  //   List<XFile?> _file = await _picker.pickMultiImage();

  //   return _file;
  // }

  // Future<XFile?> getVideo() async {
  //   XFile? mediaFiles = await _picker.pickVideo(source: ImageSource.gallery);
  //   return mediaFiles;
  // }
}
