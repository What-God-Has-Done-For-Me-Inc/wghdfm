import 'dart:io';

import 'package:mime/mime.dart';
import 'package:video_compress_ds/video_compress_ds.dart';

class FileCompressor {
  static Future<File?> compressFile({required File? file}) async {
    final mimeType = lookupMimeType(file!.path);
    if (mimeType!.startsWith('image/')) {
      return file;
    } else if (mimeType.startsWith('video/')) {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
        includeAudio: true,
      );
      return (info?.file == null || info?.path?.isEmpty == true || info?.file?.path.isEmpty == true) ? null : File(info!.file!.path);
    }
    return null;
  }
}
