import 'dart:convert';
import 'dart:io';

import 'package:camera/firebase_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool start;
  File? _cameraVideo;
  ImagePicker picker = ImagePicker();
  late VideoPlayerController _cameraVideoPlayerController;

  Future pickVideoFromCamera() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.camera);
    _cameraVideo = File(pickedFile!.path);
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo!)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.play();
      });
  }

  @override
  void dispose(){
    _cameraVideoPlayerController.dispose();
    super.dispose();
  }

  void _stop() async {
    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo!)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.pause();
      });
  }
  // void _pickVideoFromCameraStart() async {
  //   _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo!)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _cameraVideoPlayerController.play();
  //     });
  // }
  UploadTask? task;
  File? file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Picker"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_cameraVideo != null)
                  _cameraVideoPlayerController.value.isInitialized
                      ? Container(
                    height: 400,
                    width: 350,
                        child: AspectRatio(
                            aspectRatio:
                                _cameraVideoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_cameraVideoPlayerController),
                          ),
                      )
                      : Container(),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        pickVideoFromCamera();
                      },
                      child: Text("Start"),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _stop();
                      },
                      child: Text("Stop"),
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: selectFile,
                        child: Text("File"),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: uploadFile,
                        child: Text("Upload"),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      task !=null ? buildUploadStatus(task!):Container(

                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future uploadFile() async{
    if(_cameraVideo == null) return;
    final fileName = base64;
    final destinaiton = 'files/$fileName';
    task = FirebaseApi.uploadFile(destinaiton, _cameraVideo!);
    setState(() {

    });
    if(task == null)return;
    final snapshot = await task!.whenComplete((){});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download-link $urlDownload');
    Text(
      '$urlDownload',
      style: TextStyle(fontSize: 20),
    );
  }

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if(result == null) return;
    final path = result.files.single.path;
    setState(() => file = File(path!));
  }

  buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
    stream: task.snapshotEvents,
    builder: (context, snapshot){
      if(snapshot.hasData){
        final snap = snapshot.data!;
        final progress = snap.bytesTransferred / snap.totalBytes;
        final percentage = (progress * 100).toStringAsFixed(2);
        return Text(
          '$percentage %',
          style: TextStyle(fontSize: 20),
        );
      }else{
        return Container();
      }
    }
  );

}
