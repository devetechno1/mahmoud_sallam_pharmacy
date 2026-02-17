import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../helpers/camera_helper.dart';

class PrescriptionController {
  final ValueNotifier<List<XFile>> imagesVN = ValueNotifier<List<XFile>>(<XFile>[]);
  final ValueNotifier<bool> isUploadingVN = ValueNotifier<bool>(false);
  final ValueNotifier<double> progressVN = ValueNotifier<double>(0.0); // 0..1

  List<XFile> get images => imagesVN.value;

  void addImages(List<XFile> adds) {
    if (adds.isEmpty) return;
    imagesVN.value = List<XFile>.unmodifiable([...imagesVN.value, ...adds]);
  }

  void replaceAt(int index, XFile x) {
    final list = [...imagesVN.value];
    if (index < 0 || index >= list.length) return;
    list[index] = x;
    imagesVN.value = List<XFile>.unmodifiable(list);
  }

  void removeAt(int index) {
    final list = [...imagesVN.value];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    imagesVN.value = List<XFile>.unmodifiable(list);
  }

  void clearAll() {
    imagesVN.value = const <XFile>[];
  }

  Future<void> pickFromCamera() async {
    final x = await CameraHelper.getImage(true);
    if (x != null) addImages([x]);
  }

  Future<void> pickFromGalleryMulti() async {
    final picks = await CameraHelper.pickMulti();
    if (picks.isNotEmpty) addImages(picks);
  }

  void setUploading(bool v) => isUploadingVN.value = v;
  void setProgress(double p) => progressVN.value = p;

  void dispose() {
    imagesVN.dispose();
    isUploadingVN.dispose();
    progressVN.dispose();
  }
}
