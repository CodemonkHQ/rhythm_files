# Rhfiles
![Generic badge](https://img.shields.io/badge/platform-android%20|%20ios%20-blue.svg)

`Rhfiles` is a Flutter package that provides a simple and easy-to-use file picker with a built-in UI. With Rhfiles, you can quickly integrate file selection functionality into your Flutter application and get a list of selected files. Rhfiles supports picking files from the device's file system, camera, gallery, and URL.
RhUtils is there which has all the pick functionalities with compressor, cropper, etc.

## Supported Platforms

This package supports the following platforms:

- Android ✔️
- iOS ✔️

This package is designed to work for both Android and iOS platforms.

## Features

- Supports file picking from the device's file system, camera, gallery, and URL.
- Provides a built-in UI for file selection.
- Allows customization of UI elements.
- File compressor for compressing image and video files with quality controls.
- Image cropper for cropping of image files.

| <img src="https://github.com/CodemonkHQ/rhythm_files/raw/main/example/screenshot_1.png" alt="Screenshot 1" width="600"/> |
| -------------------------------------------------------------------- |
Dashboard to pick files from files, camera, gallery and link

| <img src="https://github.com/CodemonkHQ/rhythm_files/raw/main/example/screenshot_2.png" alt="Screenshot 2" width="600"/> |
| -------------------------------------------------------------------- |
Dashboard in dark mode

| <img src="https://github.com/CodemonkHQ/rhythm_files/raw/main/example/screenshot_3.png" alt="Screenshot 3" width="600"/> |
| -------------------------------------------------------------------- |
Single file added

| <img src="https://github.com/CodemonkHQ/rhythm_files/raw/main/example/screenshot_4.png" alt="Screenshot 4" width="600"/> |
| -------------------------------------------------------------------- |
Multiple files added


## Setup
- iOS 

Add two rows to the ios/Runner/Info.plist:

- one with the key Privacy - Camera Usage Description.
- one with the key Privacy - Photo Library Usage Description.



If editing Info.plist as text, add:
```Info.plist
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Access camera to pick image from gallery</string>
```

## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  rhythm_files: ^1.0.0
```

## Usage

The Rhythm Files package provides a simple way to access and manage files on mobile devices. It includes features like picking files from the device storage, selecting files from the camera or gallery, and uploading files to a server.

To use the Rhythm Files package, you need to first import it in your Dart code using the following import statement:
```dart
import 'package:rhythm_files/rhythm_files.dart';
```

After importing the package, you can create an instance of the `RhFiles` class using the instance property:
```dart
final RhFiles rhFiles = RhFiles.instance;
```
This instance provides access to various methods of the package.

### Picking Files

To `pick` files from the device storage, you can use the pick method of the `RhFiles` instance. It takes several parameters like `source`, `allowMultiple`, `fileType`, and `allowedExtensions` to customize the file picking process. The method returns a list of `File` objects that you can use to access the selected files.

Here is an example of picking multiple JPG or PNG files from the device storage:
```dart
List<File?> pickedFiles = await rhFiles.pick(
  source: Source.file,
  allowMultiple: true,
  fileType: FileType.custom,
  allowedExtensions: ['jpg', 'png'],
);
```

### Dashboard

The `dashboard` method of the `RhFiles` instance creates a simple file picking UI that you can integrate into your app. The method takes a callback function `onPick` that is called when the user selects one or more files. The selected files are passed to the callback function as a list of File objects.

Here is an example of using the dashboard method to create a file picking UI:
```dart
rhFiles.dashboard(
  onPick: (list) {
    files = list;
    setState(() {});
  },
),
```

```dart
final RhUtils utils = RhFiles.utils;
```
This creates an instance of the `RhUtils` class that can be used to call its methods.

### Image Cropper

```dart
File? croppedImage = await utils.cropImage(
  imageFile: File('path/to/image.jpg'),
  context: context,
);
```
This method allows you to crop an image file. The method takes in two required parameters: `imageFile`, which is the image file to be cropped, and `context`, which is the build context. It returns the cropped image file as a `File` object.

### Image and Video Compressor

`compressFile` method compresses a `file` (image or video) by reducing its size without compromising its quality. 
It takes in one required parameter, file, which is the original file to be compressed. 
It returns the compressed file as a `File` object.


```dart
File? compressedFile = await RhFiles.utils.compressFile(
  file: originalFile, // an image or video
);
```

`compressImage` method compresses an image file by reducing its size without compromising its quality. 
It takes in three required parameters: `image`, which is the image file to be compressed, `quality`, which is an integer value representing the quality of the compressed image, and `percentage`, which is the percentage of the original image size that the compressed image should be. 

It returns the compressed image file as a `File` object.


```dart
File? compressedFile = await RhFiles.utils.compressImage(image: imageFile, quality: 80, percentage: 50);
```

`compressVideo` method compresses a video file by reducing its size without compromising its quality. 

It takes in several parameters: `video`, which is the video file to be compressed, `videoQuality`, which is an enum representing the quality of the compressed video, `deleteOrigin`, which is a boolean value indicating whether the original video should be deleted after compression, `includeAudio`, which is a boolean value indicating whether the audio of the video should be included in the compressed video, `frameRate`, which is an integer value representing the frame rate of the compressed video, and `duration`, which is an integer value representing the maximum duration of the compressed video. 
It returns the compressed video file as a `File` object.


```dart
File? compressedVideo = await RhFiles.utils.compressVideo(
  video: File('/path/to/video.mp4'),
  videoQuality: RhVideoQuality.MediumQuality,
  deleteOrigin: true,
  includeAudio: false,
  frameRate: 30,
  duration: 60,
);
```

<!-- ![Sample Image](https://images.pexels.com/photos/1181675/pexels-photo-1181675.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1)  [![Sample video](https://q5n8c8q9.rocketcdn.me/wp-content/uploads/2019/09/YouTube-thumbnail-size-guide-best-practices-top-examples.png.webp)](http://techslides.com/demos/sample-videos/small.mp4)  -->