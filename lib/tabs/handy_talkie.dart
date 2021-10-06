import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

const APP_ID = "88569dbfe0e3476993af0f2ba17bae41";
const Token = "684b80d12bfc4c03b27795b366b062cc";

class HandyTalkie extends StatefulWidget {
  const HandyTalkie({Key? key}) : super(key: key);

  @override
  _HandyTalkieState createState() => _HandyTalkieState();
}

class _HandyTalkieState extends State<HandyTalkie> {
  int? _remoteUid;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [
      Permission.microphone
      // , Permission.camera
    ].request();

    //create the engine
    _engine = await RtcEngine.create(APP_ID);
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine.joinChannel(null, "firstchannel", null, 0);
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Voice Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: RtcLocalView.SurfaceView(
                  renderMode: VideoRenderMode.Hidden,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.TextureView(
        uid: _remoteUid!,
        renderMode: VideoRenderMode.Hidden,
      );
    } else {
      return Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}


//   bool _joined = false;
//   int _remoteUid = 0;
//   bool _switch = false;

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Init the app
//   Future<void> initPlatformState() async {
//     // Get microphone permission
//     await [Permission.microphone].request();

//     // Create RTC client instance
//     RtcEngineContext context = RtcEngineContext(APP_ID);
//     var engine = await RtcEngine.createWithContext(context);
//     // Define event handling logic
//     engine.setEventHandler(RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//       print('joinChannelSuccess ${channel} ${uid}');
//       setState(() {
//         _joined = true;
//       });
//     }, userJoined: (int uid, int elapsed) {
//       print('userJoined ${uid}');
//       setState(() {
//         _remoteUid = uid;
//       });
//     }, userOffline: (int uid, UserOfflineReason reason) {
//       print('userOffline ${uid}');
//       setState(() {
//         _remoteUid = 0;
//       });
//     }));
//     // Join channel with channel name as 123
//     await engine.joinChannel(Token, '123', null, 0);
//   }

//   // Build chat UI
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Agora Audio quickstart',
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Agora Audio quickstart'),
//         ),
//         body: Center(
//           child: Text('Please chat!'),
//         ),
//       ),
//     );
//   }
// }
