import 'dart:io';

enum MediaType {
  image,
  video,
  audio,
}

class CompressedFile {
  const CompressedFile({
    required this.originalFile,
    required this.compressedFile,
    required this.mediaType,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    this.duration,
    this.thumbnailPath,
  });

  final File originalFile;
  final File compressedFile;
  final MediaType mediaType;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final Duration? duration;
  final String? thumbnailPath;

  double get compressionPercentage => (1 - compressionRatio) * 100;

  String get fileName => compressedFile.path.split('/').last;

  bool get isImage => mediaType == MediaType.image;
  bool get isVideo => mediaType == MediaType.video;
  bool get isAudio => mediaType == MediaType.audio;
}
