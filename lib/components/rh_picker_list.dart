import 'package:file_previewer/file_previewer.dart';
import 'package:flutter/material.dart';
import 'package:rhythm_files/constant.dart';
import 'package:rhythm_files/components/rh_picker.dart';
import 'package:rhythm_files/utils/rh_files.dart';

class RhPickerListTile extends StatefulWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final Widget? divider;
  const RhPickerListTile(
      {required this.leading,
      required this.title,
      this.titleStyle,
      this.subtitleStyle,
      this.trailing,
      this.padding,
      this.decoration,
      this.divider,
      super.key,
      this.subtitle,
      this.onTap,
      this.margin});

  @override
  State<RhPickerListTile> createState() => _RhPickerListTileState();
}

class _RhPickerListTileState extends State<RhPickerListTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin,
            padding: widget.padding,
            decoration: widget.decoration,
            child: Row(
              children: [
                widget.leading,
                Column(
                  children: [
                    widget.title,
                    widget.subtitle ?? Container(),
                  ],
                ),
                const Spacer(),
                widget.trailing ?? Container(),
              ],
            ),
          ),
        ),
        widget.divider ?? const Divider(),
      ],
    );
  }
}

class RhPickerListItem extends StatefulWidget {
  final Widget? title;
  final Widget? subtitle;
  final String path;
  final Widget? removeIcon;
  final Function()? onRemove;
  final PickedItemDecoration? pickedItemDecoration;

  const RhPickerListItem({
    Key? key,
    required this.path,
    this.title,
    this.subtitle,
    this.onRemove,
    this.removeIcon,
    this.pickedItemDecoration,
  }) : super(key: key);

  @override
  State<RhPickerListItem> createState() => _RhPickerListItemState();
}

class _RhPickerListItemState extends State<RhPickerListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(
        horizontal: spacingSmall,
      ),
      child: Stack(
        children: [
          Container(
            padding: widget.pickedItemDecoration?.padding ??
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: widget.pickedItemDecoration?.decoration ??
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
            margin: const EdgeInsets.all(spacingSmall),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 45,
                  margin: const EdgeInsets.only(right: 10, top: 0),
                  decoration: widget.pickedItemDecoration?.imageDecoration ??
                      BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                  clipBehavior: Clip.hardEdge,
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: FutureBuilder<Widget>(
                        future: FilePreview.getThumbnail(
                          widget.path,
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
                      )),
                ),
                Expanded(
                  child: widget.title ??
                      Text(
                        RhFiles.utils.getLastSplit(input: widget.path),
                        maxLines: 1,
                        style: widget.pickedItemDecoration?.titleStyle ??
                            Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                ),
                const SizedBox(
                  width: spacingSmall,
                ),
                widget.subtitle ??
                    FutureBuilder<String>(
                      future: RhFiles.utils.getFileSize(widget.path),
                      builder: (context, snapshot) {
                        return Text(
                          (snapshot.data ?? ""),
                          maxLines: 1,
                          style: widget.pickedItemDecoration?.subtitleStyle ??
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
          Positioned(
            top: spacingNano,
            right: spacingNano,
            child: InkWell(
              onTap: widget.onRemove,
              child: widget.removeIcon ??
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.red, width: 1.5)),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.red,
                      size: 12,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
