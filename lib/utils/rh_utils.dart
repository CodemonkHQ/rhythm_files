import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:rhythm_files/rh_enums.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// This is a RhUtils class containing utility methods for file handling and cloud uploads.
/// To use the class, simply create an instance of RhUtils and call the desired method with the necessary parameters.
///
/// Example usage:
///
/// Create an instance of RhUtils
/// ```
/// final RhUtils utils = RhUtils.instance;
/// ```
class RhUtils {
  static final RhUtils instance = RhUtils._();

  RhUtils._();

  /// Returns a list of File objects selected from device using file picker.
  ///
  /// If [allowMultiple] is true, multiple files can be selected.
  ///
  /// [fileType] enum specifies the type of file to be picked (e.g., image, video, audio, media, any).
  ///
  /// [allowedExtensions] can be specified to filter the file types that can be selected.
  ///
  /// Returns an empty list if no files are selected.
  ///
  /// Example usage:
  /// ```
  /// List<File?> files = await RhUtils.instance.pickFilesFromDevice(
  ///   allowMultiple: true,
  ///   fileType: FileType.custom,
  ///   allowedExtensions: ['jpg', 'jpeg', 'png'],
  /// );
  /// ```
  Future<List<File?>> pickFilesFromDevice({
    required bool allowMultiple,
    required FileType fileType,
    required List<String> allowedExtensions,
  }) async {
    List<File?> files = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: fileType,
      allowedExtensions: allowedExtensions,
    );

    if (result != null) {
      files = result.paths
          .map((path) => (path == null) ? null : File(path))
          .toList();
    }
    return files;
  }

  /// Crops an image from the provided [imageFile] using the ImageCropper package.
  ///
  /// Returns a [File] object of the cropped image, or null if cropping was cancelled.
  ///
  /// Allows customization of UI settings for both Android and iOS platforms through
  /// [androidUiSettings] and [iosUiSettings].
  ///
  /// Primary theme color is used passed through required [context].
  ///
  /// Example usage:
  /// ```
  /// File? croppedImage = await RhUtils.instance.cropImage(
  ///   imageFile: File('path/to/image.jpg'),
  ///   context: context,
  /// );
  /// ```
  ///
  Future<File?> cropImage({
    required File imageFile,
    required BuildContext context,
    AndroidUiSettings? androidUiSettings,
    IOSUiSettings? iosUiSettings,
  }) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        androidUiSettings ??
            AndroidUiSettings(
              toolbarTitle: 'Crop Photo',
              toolbarColor: Theme.of(context).colorScheme.surface,
              toolbarWidgetColor:
                  (Theme.of(context).brightness == Brightness.light)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
              activeControlsWidgetColor:
                  (Theme.of(context).brightness == Brightness.light)
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
            ),
        iosUiSettings ?? IOSUiSettings(),
      ],
    );
    if (cropped == null) return null;
    return File(cropped.path);
  }

  /// Compresses a file either by reducing image quality or resizing it for image, or by
  /// compressing a video.
  ///
  /// Returns a compressed file if successful, otherwise returns null.
  ///
  /// [file] is the file to compress.
  ///
  /// Example usage:
  ///
  /// ```
  /// File? compressedFile = await RhUtils.instance.compressFile(
  ///   file: originalFile, // an image or video
  /// );
  /// ```
  Future<File?> compressFile({required File? file}) async {
    final mimeType = lookupMimeType(file!.path);
    if (mimeType!.startsWith('image/')) {
      return await RhUtils.instance.compressImage(image: file);
    } else if (mimeType.startsWith('video/')) {
      return await RhUtils.instance.compressVideo(video: file);
    }
    return null;
  }

  /// Compresses the given [image] file using FlutterNativeImage plugin and returns the compressed file as a [File] object.
  ///
  /// [quality] represents the quality of the compressed image, with a range of 0 to 100, where 100 means no compression.
  ///
  /// [percentage] represents the percentage reduction in the image size.
  ///
  /// Returns the compressed [File] object.
  ///
  /// Example Usage
  ///
  /// ```
  /// File? compressedFile = await RhUtils.instance.compressImage(image: imageFile, quality: 80, percentage: 50);
  /// ```
  Future<File?> compressImage({
    required File? image,
    int quality = 100,
    int percentage = 30,
  }) async {
    var path = await FlutterNativeImage.compressImage(image!.absolute.path,
        quality: quality, percentage: percentage);
    return path;
  }

  /// Compresses the given video file using the provided options.
  ///
  /// Returns a compressed [File] object.
  ///
  /// [videoQuality] is the quality of the compressed video. Valid values are
  /// low, medium, and high.
  ///
  /// [deleteOrigin] is whether or not to delete the original file after
  /// compression.
  ///
  /// [includeAudio] is whether or not to include the audio in the compressed
  /// video.
  ///
  /// [frameRate] is the frame rate to use when compressing the video.
  ///
  /// [duration] is the maximum duration of the compressed video, in seconds.
  ///
  /// Example usage:
  ///
  /// ```
  /// File? compressedVideo = await RhUtils.instance.compressVideo(
  ///   video: File('/path/to/video.mp4'),
  ///   videoQuality: RhVideoQuality.MediumQuality,
  ///   deleteOrigin: true,
  ///   includeAudio: false,
  ///   frameRate: 30,
  ///   duration: 60,
  /// );
  /// ```
  Future<File?> compressVideo({
    required File? video,
    RhVideoQuality? videoQuality,
    bool deleteOrigin = false,
    bool? includeAudio,
    int frameRate = 30,
    int? duration,
  }) async {
    VideoQuality quality;
    switch (videoQuality) {
      case RhVideoQuality.HighestQuality:
        quality = VideoQuality.HighestQuality;
        break;
      case RhVideoQuality.LowQuality:
        quality = VideoQuality.LowQuality;
        break;
      case RhVideoQuality.MediumQuality:
        quality = VideoQuality.MediumQuality;
        break;
      case RhVideoQuality.Res1280x720Quality:
        quality = VideoQuality.Res1280x720Quality;
        break;
      case RhVideoQuality.Res1920x1080Quality:
        quality = VideoQuality.Res1920x1080Quality;
        break;
      case RhVideoQuality.Res640x480Quality:
        quality = VideoQuality.Res640x480Quality;
        break;
      case RhVideoQuality.Res960x540Quality:
        quality = VideoQuality.Res960x540Quality;
        break;
      default:
        quality = VideoQuality.DefaultQuality;
    }
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      video!.path,
      quality: quality,
      deleteOrigin: deleteOrigin,
      includeAudio: includeAudio,
      frameRate: frameRate,
      duration: duration,
    );
    return mediaInfo?.file;
  }

  /// Returns a human-readable string representation of the size of the specified [file] in bytes,
  /// using the filesize package. If the File is null, the method returns an empty string.

  /// [pickImagesFromDevice] Launches image picker to allow user to select one or multiple images from their device
  ///
  /// [source] specifies where to get the images from, either the gallery or the camera.
  ///
  /// [preferredCameraDevice] specifies which camera to use in case the user selects the camera as the source.
  ///
  /// Returns a list of [File] objects containing the selected images.
  ///
  /// Example usage:
  /// ```
  /// List<File?> images = await RhUtils.instance.pickImagesFromDevice(source: ImageSource.camera);
  /// ```
  Future<List<File?>> pickImagesFromDevice({
    required ImageSource source,
    CameraDevice? preferredCameraDevice,
  }) async {
    List<File?> files = [];
    final image = await ImagePicker().pickImage(
        source: source,
        preferredCameraDevice: preferredCameraDevice ?? CameraDevice.rear);
    if (image == null) return files;
    File? img = File(image.path);
    files.add(img);
    return files;
  }

  /// Downloads file from the given [source] URL and saves it to a temporary directory on the device.
  ///
  /// Returns a list of Files containing the downloaded file.
  ///
  /// Example usage:
  /// ```
  /// List<File?> files = await RhUtils.instance.getFileFromUrl(source: 'https://example.com/image.jpg');
  /// ```
  Future<List<File?>> getFileFromUrl({required String source}) async {
    List<File?> files = [];

    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath${Random().nextInt(100)}.png');
    http.Response response = await http.get(Uri.parse(source));
    await file.writeAsBytes(response.bodyBytes);

    files.add(file);
    return files;
  }

  /// Uploads one or more image files to Cloudinary using the specified upload preset and cloud name.
  ///
  /// [paths] is a list of file paths to upload.
  ///
  /// [uploadPreset] is the upload preset to use for the upload.
  ///
  /// [cloudName] is the name of the Cloudinary account to upload the files to.
  ///
  /// [onProgress] is an optional callback function that is called with the current progress of the upload, as a percentage.
  ///
  /// [onException] is an optional callback function that is called if an exception occurs during the upload.
  /// The function is passed a CloudinaryException object.
  ///
  /// Example usage:
  /// ```
  /// RhUtils.instance.cloudinaryUpload(
  ///   paths: ['/path/to/image1.jpg', '/path/to/image2.png'],
  ///   uploadPreset: 'upload_preset',
  ///   cloudName: 'cloud_name',
  ///   onProgress: (sent, total) => print('$sent of $total bytes uploaded'),
  ///   onException: (e) => print('Upload failed: ${e.message}'),
  /// );
  /// ```
  void cloudinaryUpload({
    required List<String> paths,
    required String uploadPreset,
    required String cloudName,
    void Function(int, int)? onProgress,
    Function(CloudinaryException)? onException,
  }) async {
    final cloudinary = CloudinaryPublic(cloudName, uploadPreset);

    if (paths.isNotEmpty) {
      try {
        for (var path in paths) {
          await cloudinary.uploadFile(
              CloudinaryFile.fromFile(path,
                  resourceType: CloudinaryResourceType.Image),
              onProgress: onProgress);
        }
      } on CloudinaryException catch (e) {
        if (onException != null) {
          onException(e);
        }
      }
    }
  }

  /// CRUD over List<File> via multipart request
  ///
  /// [headers] is a map of HTTP headers to send with the request
  ///
  /// [body] is a map of key-value pairs to include in the request body
  ///
  /// [files] is a map of pathName and List of paths to include in the request body
  ///
  /// [url] is the URL to send request
  ///
  /// [method] is the HTTP method to use (e.g. GET, POST, PUT, DELETE)
  ///
  /// Example usage:
  /// ```
  /// await RhUtils.instance.multipartUpload(
  ///   files: {'avatar': ['/path/to/avatar.jpg', '/path/to/avatar.png']},
  ///   url: 'https://example.com/api/users',
  ///   method: HttpMethod.post,
  /// );
  /// ```
  Future<http.StreamedResponse?> multipartUpload({
    Map<String, String>? headers,
    Map<String, String>? body,
    required Map<String, List<String>> files,
    required String url,
    required String method,
  }) async {
    http.StreamedResponse? response;

    var request = http.MultipartRequest(
      method,
      Uri.parse(url),
    );
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.fields.addAll(body);
    }
    if (files.isNotEmpty) {
      files.forEach((pathName, paths) async {
        for (var path in paths) {
          final multipart = await http.MultipartFile.fromPath(
            pathName,
            path,
          );
          request.files.add(multipart);
        }
      });
      response = await request.send();
    }

    return response;
  }

  /// [multiPartProgress]  Returns a stream of the multipart progress for the given HTTP [response].
  ///
  /// The stream will emit doubles representing the percentage of bytes received.
  ///
  /// Example usage:
  /// ```
  /// RhUtils.instance.multiPartProgress(response: response).listen((event) {
  ///   // Functions using [event]
  /// });
  /// ```
  Stream<double> multiPartProgress({required http.StreamedResponse response}) {
    final controller = StreamController<double>();
    final totalBytes = response.contentLength ?? -1;
    var receivedBytes = 0;

    response.stream.listen(
      (List<int> chunk) {
        receivedBytes += chunk.length;
        if (totalBytes >= 0) {
          final percentage = (receivedBytes / totalBytes) * 100;
          controller.add(percentage);
        }
      },
      onDone: () {
        controller.close();
      },
      onError: (error) {
        controller.addError(error);
      },
      cancelOnError: true,
    );

    return controller.stream;
  }

  Future<String> getFileSize(String filepath) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ('${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}')
        .toString();
  }

  /// Gets last string after splitting [input] whole by '/'
  String getLastSplit({required String input}) {
    final splitted = input.split('/');
    return splitted.last;
  }
}
