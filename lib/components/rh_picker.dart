import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_previewer/file_previewer.dart';
import 'package:rhythm_files/constant.dart';
import 'package:rhythm_files/rh_enums.dart';
import 'package:rhythm_files/components/rh_picker_list.dart';
import 'package:rhythm_files/utils/rh_files.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class RhFilePicker extends StatefulWidget {
  /// [type] specifies whether to pick a single file or multiple files
  final PickerType type;

  /// [removeIcon] is an optional widget to display on each selected file for removing it from the selection
  final Widget? removeIcon;

  /// [uploadIcon] is the icon to be used for the upload button
  final Widget? uploadIcon;

  /// [fileType] specifies the type of file to be picked
  final FileType? fileType;

  /// [allowedExtensions] specifies the list of allowed file extensions
  final List<String>? allowedExtensions;

  /// [onPick] is the callback function to be called when a file or files are picked
  final Function(List<File?>)? onPick;

  /// [margin] for the content inside the Multiple picker
  final EdgeInsets? margin;

  /// [backgroundColor] of the picker widget
  final Color? backgroundColor;

  /// [addMore] widget customisable for the user
  final Widget? addMore;

  /// [showSelected] widget customisable for the user
  final Widget? showSelected;

  /// [children] is a list of ListItem used as options in Multipicker
  final List<Widget> children;

  /// [headerText] is the widget user wants in
  final Widget? headerText;

  /// [selectedFiles] is a widget that shows the selected files in the picker.
  final Widget? selectedFiles;

  /// [pickedItemDecoration] is the decoration for the selected items in the picker.
  final PickedItemDecoration? pickedItemDecoration;

  /// [singleItemDecoration] is the decoration for the single item picker.
  final PickedItemDecoration? singleItemDecoration;

  // final Widget Function(List<File?>)? pickedItemsBuilder;
  // final bool defaultDisabled;

  /// [title] is a widget that shows the title of the picker.
  final Widget? title;

  /// [subtitle] is a widget that shows the subtitle of the picker.
  final Widget? subtitle;

  /// [source] is a variable that holds the source of the files, which could be from the device, camera, gallery, or a link.
  final Source? source;

  const RhFilePicker.single({
    super.key,
    this.removeIcon,
    this.uploadIcon,
    this.onPick,
    this.fileType = FileType.any,
    this.allowedExtensions,
    this.backgroundColor,
    this.pickedItemDecoration,
    this.title,
    this.subtitle,
    required this.source,
  })  : type = PickerType.single,
        children = const [],
        selectedFiles = null,
        singleItemDecoration = null,
        margin = null,
        headerText = null,
        addMore = null,
        showSelected = null;

  const RhFilePicker.multiple({
    super.key,
    this.removeIcon,
    this.fileType = FileType.any,
    this.onPick,
    this.allowedExtensions,
    this.children = const [],
    this.margin,
    this.backgroundColor,
    this.addMore,
    this.showSelected,
    this.headerText,
    this.selectedFiles,
    this.pickedItemDecoration,
    this.singleItemDecoration,
  })  : uploadIcon = null,
        type = PickerType.multiple,
        title = null,
        subtitle = null,
        source = null;

  @override
  State<RhFilePicker> createState() => _RhFilePickerState();
}

class _RhFilePickerState extends State<RhFilePicker> {
  List<File?> files = [];

  bool _isLinkEditable = false;
  bool _preview = false;
  String _fileLink = "";

  final _formKey = GlobalKey<FormState>();

  Widget iconBuilder(Widget icon) {
    return Container(
      margin: const EdgeInsets.all(spacingSmall),
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              offset: const Offset(0.0, 0.0),
              blurRadius: 2.0,
              spreadRadius: 1.0,
            ),
          ]),
      child: icon,
    );
  }

  List<Widget> _options() {
    List<Widget> rhDefaultOptions = [
      RhPickerListTile(
        leading:
            iconBuilder(const Icon(FluentIcons.folder_16_regular, size: 30)),
        title: Text(
          "My Device",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () async {
          List<File?> pickedFiles =
              await RhFiles.instance.pick(source: Source.file);
          if (pickedFiles.isNotEmpty && pickedFiles[0] != null) {
            files.addAll(pickedFiles);
            if (pickedFiles.isNotEmpty) {
              _preview = false;
            }
            setState(() {});
          }
          if (widget.onPick != null) {
            widget.onPick!(files);
            _isLinkEditable = false;
          }
        },
      ),
      RhPickerListTile(
        leading:
            iconBuilder(const Icon(FluentIcons.camera_16_regular, size: 30)),
        title: Text(
          "Camera",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () async {
          List<File?> pickedFiles =
              await RhFiles.instance.pick(source: Source.camera);
          if (pickedFiles.isNotEmpty && pickedFiles[0] != null) {
            files.addAll(pickedFiles);
            if (pickedFiles.isNotEmpty) {
              _preview = false;
            }
            setState(() {});
          }
          if (widget.onPick != null) {
            widget.onPick!(files);
            _isLinkEditable = false;
          }
        },
      ),
      RhPickerListTile(
        leading:
            iconBuilder(const Icon(FluentIcons.image_16_regular, size: 30)),
        title: Text(
          "Gallery",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: () async {
          List<File?> pickedFiles =
              await RhFiles.instance.pick(source: Source.gallery);
          if (pickedFiles.isNotEmpty && pickedFiles[0] != null) {
            files.addAll(pickedFiles);
            if (pickedFiles.isNotEmpty) {
              _preview = false;
            }

            setState(() {});
          }
          if (widget.onPick != null) {
            widget.onPick!(files);
            _isLinkEditable = false;
          }
        },
      ),
      (_isLinkEditable)
          ? Container(
              margin: const EdgeInsets.symmetric(vertical: spacingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Enter Link',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: spacingSmall, horizontal: spacingSmall),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        validator: (value) {
                          if (_fileLink.isEmpty) {
                            return "Please a link";
                          }
                          return null;
                        },
                        onChanged: (text) {
                          _fileLink = text;
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        List<File?> pickedFile = await RhFiles.instance.pick(
                          source: Source.url,
                          fileUrl: _fileLink,
                        );
                        if (pickedFile.isNotEmpty) {
                          _fileLink = "";
                        }
                        _isLinkEditable = false;
                        files.addAll(pickedFile);
                        _preview = false;

                        setState(() {});
                        if (widget.onPick != null) {
                          widget.onPick!(files);
                          _isLinkEditable = false;
                        }
                      }
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.all(spacingSmall),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withOpacity(0.9)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[400]!,
                              offset: const Offset(0.0, 0.0),
                              blurRadius: 2.0,
                              spreadRadius: 1.0,
                            ),
                          ]),
                      child: const Text("Add File"),
                    ),
                  ),
                ],
              ),
            )
          : RhPickerListTile(
              leading: iconBuilder(
                  const Icon(FluentIcons.link_12_regular, size: 30)),
              title: Text(
                "Link",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                _isLinkEditable = true;
                setState(() {});
              },
              divider: Container(),
            ),
    ];

    return rhDefaultOptions;
  }

  Widget _pickers() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          margin: widget.margin ?? const EdgeInsets.only(left: 30, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.headerText ??
                  Text(
                    'Pick files from:',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[800]
                            : Colors.white),
                  ),
              _preview
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          _preview = !_preview;
                        });
                      },
                      child: widget.showSelected ??
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Text(
                                "Show selected",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                          ),
                    )
                  : Container(),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._options(),
            ],
          ),
        ),
      ],
    );
  }

  void remove({required int index}) {
    _isLinkEditable = false;
    setState(() {
      files.removeAt(index);
    });
  }

  String getLastSplit(String input) {
    final splitted = input.split('/');
    return splitted.last;
  }

  Widget _singleItemPreview(String path) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: widget.singleItemDecoration?.decoration ??
              BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 1.0,
                    spreadRadius: 0,
                  )
                ],
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
          margin: const EdgeInsets.all(spacingBase),
          child: Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: MediaQuery.of(context).size.height * 0.25,
                  margin: const EdgeInsets.all(spacingSmall),
                  decoration: widget.singleItemDecoration?.imageDecoration ??
                      BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                  clipBehavior: Clip.hardEdge,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: FutureBuilder<Widget>(
                        future: FilePreview.getThumbnail(
                          path,
                          height: 50,
                          width: 80,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 50,
                              width: 80,
                            );
                          }
                          if (snapshot.hasData) {
                            return snapshot.data ?? Container();
                          } else {
                            return const SizedBox(
                              height: 50,
                              width: 80,
                            );
                          }
                        },
                      ))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * (0.55),
                      child: Text(
                        RhFiles.utils.getLastSplit(input: path),
                        maxLines: 1,
                        style: widget.singleItemDecoration?.titleStyle ??
                            Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    const Spacer(),
                    FutureBuilder<String>(
                      future: RhFiles.utils.getFileSize(path),
                      builder: (context, snapshot) {
                        return Text(
                          (snapshot.data ?? "").toString(),
                          maxLines: 1,
                          style: widget.singleItemDecoration?.subtitleStyle ??
                              TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                          overflow: TextOverflow.visible,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: spacingSmall,
          right: spacingSmall,
          child: InkWell(
            onTap: () {
              remove(index: 0);
            },
            child: widget.removeIcon ??
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 1.5)),
                  child: const Icon(
                    Icons.clear,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.type == PickerType.multiple) ...{
            Container(
              margin: const EdgeInsets.symmetric(vertical: spacingBase),
              padding: const EdgeInsets.only(bottom: spacingBase),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Theme.of(context).brightness == Brightness.dark
                    ? widget.backgroundColor ?? Colors.black.withOpacity(0.3)
                    : widget.backgroundColor ?? Colors.black.withOpacity(0.04),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              // height: MediaQuery.of(context).size.height * 0.45,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_preview || files.isEmpty) ...{
                    _pickers()
                  } else ...{
                    Column(
                      children: [
                        const SizedBox(height: spacingBase),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                  top: spacingSmall,
                                  left: spacingSmall,
                                  bottom: spacingSmall),
                              alignment: Alignment.topLeft,
                              child: widget.selectedFiles ??
                                  Text("Selected Files",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isLinkEditable = false;
                                  _preview = !_preview;
                                });
                              },
                              child: widget.addMore ??
                                  Container(
                                    margin: const EdgeInsets.only(right: 20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Add more files",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                        if (files.isNotEmpty && !_preview) ...{
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.36,
                            child: (files.length == 1)
                                ? _singleItemPreview(files.first?.path ?? "")
                                : ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: files.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return RhPickerListItem(
                                        path: files[index]?.path ?? "",
                                        onRemove: () {
                                          remove(index: index);
                                        },
                                        removeIcon: widget.removeIcon,
                                        pickedItemDecoration:
                                            widget.pickedItemDecoration,
                                      );
                                    },
                                  ),
                          ),
                        }
                      ],
                    )
                  }
                ],
              ),
            )
          } else ...{
            if (files.isEmpty) ...{
              Container(
                margin: const EdgeInsets.only(
                    left: 28, right: 30, top: 10, bottom: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: widget.pickedItemDecoration?.decoration ??
                    BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? widget.backgroundColor ??
                                  Colors.black.withOpacity(0.9)
                              : widget.backgroundColor ?? Colors.grey[400]!,
                          offset: const Offset(0.0, 0.0),
                          blurRadius: 1.0,
                          spreadRadius: 0,
                        )
                      ],
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    final pickedFiles = await RhFiles.instance.pick(
                        source: widget.source ?? Source.file,
                        allowedExtensions: widget.allowedExtensions ?? [],
                        fileType: widget.fileType ?? FileType.any);
                    if (pickedFiles.isNotEmpty && pickedFiles[0] != null) {
                      files.addAll(pickedFiles);
                      if (pickedFiles.isNotEmpty) {
                        _preview = false;
                      }
                      setState(() {});
                      if (widget.onPick != null) {
                        widget.onPick!(files);
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 50,
                        margin: const EdgeInsets.only(right: 10, top: 0),
                        child: widget.uploadIcon ??
                            Icon(Icons.cloud_upload_outlined,
                                size: 40, color: Colors.grey[600]),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: widget.title ??
                                Text(
                                  "Pick a file",
                                  style:
                                      widget.pickedItemDecoration?.titleStyle ??
                                          Theme.of(context).textTheme.bodyLarge,
                                ),
                          ),
                          widget.subtitle ?? Container()
                        ],
                      ),
                    ],
                  ),
                ),
              )
            } else ...{
              Container(
                margin: const EdgeInsets.all(8),
                child: files.isNotEmpty && widget.type == PickerType.single
                    ? RhPickerListItem(
                        path: files.first?.path ?? '',
                        onRemove: () async {
                          remove(index: 0);
                        },
                        removeIcon: widget.removeIcon,
                        pickedItemDecoration: widget.pickedItemDecoration,
                      )
                    : Container(),
              ),
            }
          }
        ],
      ),
    );
  }
}

class PickedItemDecoration {
  BoxDecoration? decoration;
  BoxDecoration? imageDecoration;
  TextStyle? titleStyle;
  TextStyle? subtitleStyle;
  EdgeInsetsGeometry? padding;

  PickedItemDecoration({
    this.decoration,
    this.imageDecoration,
    this.titleStyle,
    this.subtitleStyle,
    this.padding,
  });
}
