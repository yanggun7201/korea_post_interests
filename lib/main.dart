import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:korea_post_interests/firebase_options.dart';
import 'package:korea_post_interests/models/Message.dart';
import 'package:korea_post_interests/providers/MessageProvider.dart';
import 'package:korea_post_interests/utils/snack_bar_utils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final messageData = message.data;
  final messageTitle = message.notification?.title ?? messageData['title'];

  final messageProvider = Provider.of<MessageProvider>(navigatorKey.currentState!.context, listen: false);
  List<dynamic> items = jsonDecode(messageData["items"]);
  if (items.isEmpty) {
    return;
  }

  for (var item in items) {
    messageProvider.addMessage(
      Message(
        keyword: messageTitle,
        title: item['title'] ?? '',
        postId: item['postId'] ?? 0,
        link: item['link'] ?? '',
        date: item['date'] ?? '',
      ),
    );
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");

  runApp(
    ChangeNotifierProvider(
      create: (context) => MessageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Korea Post Interests',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Korea Post Interests'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String myFcmToken = '';

  @override
  void initState() {
    super.initState();

    setupInteractedMessage();
  }

  Future<void> setupInteractedMessage() async {
    Future.delayed(Duration.zero, () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      var fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("____________________________fcmToken: $fcmToken");
        setState(() {
          myFcmToken = fcmToken;
        });
      }

      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      print('________________ User granted permission: ${settings.authorizationStatus}');

      // Get any messages which caused the application to open from
      // a terminated state.
      RemoteMessage? initialMessage = await messaging.getInitialMessage();

      if (initialMessage != null) {
        _firebaseMessagingBackgroundHandler(initialMessage);
      }

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
    });
  }

  void _incrementCounter() {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final newMessage = Message(
        keyword: '자전거', title: '자전거 좀 사 줘요 ', postId: 1000, link: "https://google.com/", date: "2023.04.01 (토)");

    print("newMessage: $newMessage");

    messageProvider.addMessage(newMessage);
  }

  void _clearAllMessages() {
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    messageProvider.clearAllMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          _buildShowFcmTokenButton(),
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              if (messageProvider.messages.isEmpty) {
                return const SizedBox(height: 500, child: Center(child: Text("새로운 데이터가 없습니다.")));
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: messageProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = messageProvider.messages[index];
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(message.keyword),
                          Text(message.date, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      subtitle: Text(message.title),
                      // trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        _launchUrl(Uri.parse(message.link));
                        messageProvider.removeMessage(message);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAllMessages,
        tooltip: 'Clear All',
        child: const Icon(Icons.refresh),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      print('Could not launch $url');
      SnackBarUtils.showSnackBar(context, 'Could not launch $url');
    }
  }

  Widget _buildShowFcmTokenButton() {
    return ElevatedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: myFcmToken));
        // SnackBarUtils.showSnackBar(context, "푸시코드가 클립보드에 복사되었습니다.");
      },
      child: Text('푸시코드 복사하기'),
    );
  }
}
