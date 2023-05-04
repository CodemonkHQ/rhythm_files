import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rhythm_files/rh_enums.dart';
import 'package:rhythm_files/components/rh_picker.dart';
import 'rh_utils.dart';

class RhFiles {
  static final RhFiles instance = RhFiles._();
  static final utils = RhUtils.instance;
  RhFiles._();

  /// Opens the device camera, gallery, file explorer or a file based on the provided [source],
  /// and allows the user to pick one or more files according to the specified parameters.
  ///
  /// Returns a List of [File] objects picked by the user.
  ///
  /// [source] is the source from which to pick the files. Valid values are
  /// Source.camera, Source.gallery, Source.file, and Source.url.
  ///
  /// [context] is the [BuildContext] object used to show the dialogs to the user. Required when
  /// picking files from camera or gallery.
  ///
  /// [fileUrl] is the URL of the file to pick when [source] is Source.url.
  ///
  /// [allowMultiple] is whether or not to allow the user to select multiple files.
  ///
  /// [fileType] is the type of files to show when [source] is Source.file.
  ///
  /// [allowedExtensions] is a list of file extensions to show when [source] is Source.file and [fileType]
  /// is FileType.custom. The extensions should be in lowercase without the leading period.
  ///
  /// [preferredCameraDevice] is the preferred camera device to use when [source] is Source.camera.
  ///
  /// Example usage:
  ///
  /// ```
  /// List<File?> pickedFiles = await RhFiles.instance.pick(
  ///   source: Source.file,
  ///   allowMultiple: true,
  ///   fileType: FileType.custom,
  ///   allowedExtensions: ['jpg', 'png'],
  /// );
  /// ```
  Future<List<File?>> pick({
    required Source source,
    BuildContext? context,
    String? fileUrl,
    bool allowMultiple = true,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
    CameraDevice? preferredCameraDevice,
  }) async {
    final utils = RhUtils.instance;
    switch (source) {
      case Source.camera:
        return utils.pickImagesFromDevice(
            source: ImageSource.camera,
            preferredCameraDevice: preferredCameraDevice);
      case Source.gallery:
        return utils.pickImagesFromDevice(
            source: ImageSource.gallery,
            preferredCameraDevice: preferredCameraDevice);
      case Source.file:
        return utils.pickFilesFromDevice(
            allowMultiple: allowMultiple,
            fileType: fileType,
            allowedExtensions: allowedExtensions ?? []);
      case Source.url:
        assert(fileUrl != null && fileUrl != "");
        return utils.getFileFromUrl(source: fileUrl!);
    }
  }

  /// Returns a widget that displays a dashboard for picking multiple files.
  ///
  /// The [removeIcon] is the widget to display for removing a file from the list
  /// of selected files.
  ///
  /// The [onPick] is the callback that is invoked when files are picked.
  ///
  /// The [margin] is the margin to apply to the widget.
  ///
  /// The [backgroundColor] is the background color to apply to the widget.
  ///
  /// The [addMore] is the widget to display for adding files to the list of
  /// selected files.
  ///
  /// The [showSelected] is the widget to display for cancelling file selection.
  ///
  /// Example usage:
  ///
  /// ```
  /// RhFiles.instance.dashboard(
  ///   onPick: (list) {
  ///     files = list;
  ///     setState(() {});
  ///   },
  /// ),
  /// ```
  Widget dashboard({
    Widget? removeIcon,
    Function(List<File?>)? onPick,
    EdgeInsets? margin,
    Color? backgroundColor,
    PickedItemDecoration? pickedItemDecoration,
    PickedItemDecoration? singleItemDecoration,
    Widget? headerText,
    Widget? selectedFiles,
    Widget? addMore,
    Widget? showSelected,
  }) {
    return RhFilePicker.multiple(
      removeIcon: removeIcon,
      onPick: onPick,
      margin: margin,
      backgroundColor: backgroundColor,
      pickedItemDecoration: pickedItemDecoration,
      singleItemDecoration: singleItemDecoration,
      headerText: headerText,
      selectedFiles: selectedFiles,
      addMore: addMore,
      showSelected: showSelected,
    );
  }

  /// A widget that displays a file picker dialog for selecting a single file.
  ///
  /// This widget displays a dialog that allows the user to pick a single file from
  /// their device's file system. The file picker dialog can be customized with
  /// various parameters, such as the allowed file types and the text styling of
  /// the dialog.
  ///
  /// [onPick] is a callback function that is invoked when the user selects a file.
  /// The selected file is returned as a List<File?> object.
  ///
  /// [removeIcon] is an optional widget that is displayed next to each selected file,
  /// allowing the user to remove the file from the list.
  ///
  /// [uploadIcon] is an optional widget that is displayed in the file picker dialog,
  /// allowing the user to upload a file from their device.
  ///
  /// [fileType] is the type of file that the file picker dialog will display. This can
  /// be set to [FileType.image], [FileType.video], [FileType.audio], or [FileType.any].
  ///
  /// [allowedExtensions] is a list of allowed file extensions for the file picker dialog.
  ///
  Widget picker({
    Function(List<File?>)? onPick,
    required Source source,
    Widget? removeIcon,
    Widget? uploadIcon,
    Widget? title,
    Widget? subtitle,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
    PickedItemDecoration? pickedItemDecoration,
  }) {
    return RhFilePicker.single(
      onPick: onPick,
      removeIcon: removeIcon,
      pickedItemDecoration: pickedItemDecoration,
      uploadIcon: uploadIcon,
      fileType: fileType,
      source: source,
      title: title,
      subtitle: subtitle,
      allowedExtensions: allowedExtensions,
    );
  }
}
