import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mediaframe/media_asset.dart';
import 'package:mediaframe/settings_model.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

const THUMBNAIL_SIZE = 200.0;

class AssetsRoute extends StatefulWidget {
  @override
  State createState() => _AssetsState();
}

class _AssetsState extends State<AssetsRoute> {
  final Set<MediaAsset> _selections = Set();

  _selectAsset(asset) {
    setState(() {
      this._selections.add(asset);
    });
  }

  _deselectAsset(asset) {
    setState(() {
      this._selections.remove(asset);
    });
  }

  Widget buildGridView(settings) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: (MediaQuery.of(context).size.width / THUMBNAIL_SIZE).floor(),
        childAspectRatio: 0.8,
      ),
      itemCount: settings.assets.length,
      itemBuilder: (context, index) {
        MediaAsset asset = settings.assets[index];

        return _AssetThumbnail(
            asset: asset,
            selected: this._selections.contains(asset),
            onSelect: () {
              this._selectAsset(asset);
            },
            onDeselect: () {
              this._deselectAsset(asset);
            });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(builder: (BuildContext context, SettingsModel model, Widget child) {
      final selectionAppBar = AppBar(title: Text('${this._selections.length} selected'), actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            setState(() {
              model.assets = model.assets.where((asset) => !this._selections.contains(asset)).toList();
              this._selections.clear();
            });
          },
        )
      ]);

      final addAssets = () async {
        List<File> files = await FilePicker.getMultiFile(
          type: FileType.media,
        );
        if (files != null) {
          final assetSet = Set<MediaAsset>.from(model.assets)..addAll(files.map((file) => MediaAsset.file(file)));
          model.assets = assetSet.toList();
        }
      };

      final overflowMenu = PopupMenuButton<String>(
          onSelected: (String result) {
            setState(() {
              this._selections.addAll(model.assets);
            });
          },
          itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'select',
                  enabled: this._selections.length > 0,
                  child: Text('Select all'),
                ),
              ]);

      final appBar = AppBar(title: Text('Slideshow Media'), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: addAssets,
        ),
        overflowMenu,
      ]);

      return Scaffold(
          appBar: this._selections.isEmpty ? appBar : selectionAppBar,
          body: Center(child: model.assets.isEmpty ? OutlineButton(child: Text('Add Slideshow Media'), onPressed: addAssets) : buildGridView(model)));
    });
  }
}

class _AssetThumbnail extends StatefulWidget {
  final MediaAsset _asset;
  final VoidCallback _onSelect;
  final VoidCallback _onDeselect;
  final bool _selected;

  _AssetThumbnail({asset: MediaAsset, selected: bool, onSelect: VoidCallback, onDeselect: VoidCallback})
      : this._asset = asset,
        this._selected = selected,
        this._onSelect = onSelect,
        this._onDeselect = onDeselect,
        super(key: Key(asset.file.path));

  @override
  State<StatefulWidget> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<_AssetThumbnail> {
  Future<ImageProvider> _assetImageProvider;

  @override
  void initState() {
    super.initState();
    this._assetImageProvider = this._loadAsset();
  }

  Future<ImageProvider> _loadAsset() async {
    if (this.widget._asset.video) {
      return MemoryImage(await VideoThumbnail.thumbnailData(
        video: this.widget._asset.file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: THUMBNAIL_SIZE.floor(), // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      ));
    } else {
      return ResizeImage(FileImage(this.widget._asset.file), width: THUMBNAIL_SIZE.floor());
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = Colors.blueAccent;
    final unselectedColor = Colors.black87;

    return FutureBuilder(
        future: this._assetImageProvider,
        builder: (context, AsyncSnapshot<ImageProvider> snapshot) {
          final imageWidget = snapshot.hasData && snapshot.data != null
              ? Center(
                  child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage), image: snapshot.data, fit: BoxFit.cover, width: THUMBNAIL_SIZE, height: THUMBNAIL_SIZE),
                )
              : Center(child: Container());

          final selectedIndicatorWidget = Visibility(
            visible: this.widget._selected,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                shape: BoxShape.circle,
                color: this.widget._selected ? selectedColor : unselectedColor,
              ),
              child: Icon(
                Icons.check,
                size: 24.0,
                color: Colors.white,
              ),
            ),
          );

          return GestureDetector(
              onLongPress: () {
                setState(() {
                  if (this.widget._selected) {
                    this.widget._onDeselect();
                  } else {
                    this.widget._onSelect();
                  }
                });
              },
              child: Card(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(flex: 2, child: imageWidget),
                Expanded(flex: 1, child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: this.widget._selected ? selectedIndicatorWidget : Icon(this.widget._asset.video ? Icons.video_label : Icons.image, size: 34.0),
                      ),
                      Expanded(flex: 1, child: Text(this.widget._asset.file.path.split("/")?.last, overflow: TextOverflow.ellipsis))
                    ])))
              ])));
        });
  }
}
