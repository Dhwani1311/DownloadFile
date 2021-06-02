import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Dio dio = Dio();
  bool loading = false;
  String progress = 'Initializing ...';
  double _progress = 0;
  String url;

  Future<bool> saveFile(url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/RPSApp";
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.storage)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      File saveFile = File(directory.path + "/$fileName");
      print(saveFile.path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        return false;
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: _onReceiveProgress);
        if (Platform.isIOS) {
          OpenFile.open(saveFile.path).then((_result) {
            print(_result);
            ImageGallerySaver.saveFile(saveFile.path, isReturnPathOfIOS: true);
          }).catchError((error) {
            print("Could not open file $error");
          });
        } else {
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _onReceiveProgress(int received, int total) {
    var percentage = received / total * 100;
    _progress = percentage / 100;
    setState(() {
      progress = 'Downloading ...${percentage.toStringAsFixed(0)} %';
      // print(received);
      // print(total);
      print(progress);
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadPhoto() async {
    setState(() {
      loading = true;
      _progress = 0;
    });
    bool downloaded = await saveFile(
        'https://i.picsum.photos/id/866/300/200.jpg?hmac=vwkhhp_0HQtgJfxWytDiH1t2GX4YyYyWs3_18hlicBY',
        'Photo.jpg');
    if (downloaded) {
      print("Download  complete");
    } else {
      print('problem Downloading File');
    }
    setState(() {
      loading = false;
    });
  }

  downloadVideo() async {
    setState(() {
      loading = !loading;
      _progress = 0;
    });
    bool downloaded = await saveFile(
        "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
        "video.mp4");
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

  downloadPdf() async {
    setState(() {
      loading = true;
      _progress = 0;
    });

    bool downloaded = await saveFile(
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
        "File.pdf");
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Downloading File')),
      ),
      body: Center(
        child: loading
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: _progress,
                ),
              ),
              Center(child: Text(progress))
            ],
          ),
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton.icon(
                  icon: Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ),
                  color: Colors.blue,
                  onPressed: downloadPhoto,
                  padding: const EdgeInsets.all(10),
                  label: Text(
                    "Download Photo",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton.icon(
                  icon: Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ),
                  color: Colors.blue,
                  onPressed: downloadVideo,
                  padding: const EdgeInsets.all(10),
                  label: Text(
                    "Download Video",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton.icon(
                  icon: Icon(
                    Icons.download_rounded,
                    color: Colors.white,
                  ),
                  color: Colors.blue,
                  onPressed: downloadPdf,
                  padding: const EdgeInsets.all(10),
                  label: Text(
                    "Download PDF",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
