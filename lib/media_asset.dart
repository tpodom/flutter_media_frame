import 'dart:io';

bool _isVideo(File file) {
  return RegExp(
    r"(webm|mov|mp4|mkv)$",
    caseSensitive: false,
    multiLine: false,
  ).hasMatch(file.path);
}

bool _isImage(File file) {
  return RegExp(
    r"(png|jpg|jpeg|gif|webp|bmp)$",
    caseSensitive: false,
    multiLine: false,
  ).hasMatch(file.path);
}

class MediaAsset {
  final File file;

  MediaAsset.file(File file) : this.file = file;

  MediaAsset.path(String path) : this.file = File(path);

  get video => _isVideo(this.file);

  get image => _isImage(this.file);

}
