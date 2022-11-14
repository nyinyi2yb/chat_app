import 'dart:ui';

import 'package:chat_app/auth/login.dart';
import 'package:chat_app/network/firebase_api.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? loggedinUser;

  String messageText = "";
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _textController = TextEditingController();

  bool isLoading = false;
  Color mainColor = const Color.fromARGB(255, 84, 0, 84);

  _scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn);
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() {
    loggedinUser = _auth.currentUser;
  }

  _sendMessage() {
    if (messageText != "") {
      _firestore.collection("messages").add({
        "sender": loggedinUser!.email,
        "text": messageText,
        "timestamp": DateTime.now()
      }).then((value) {
        _textController.text = "";
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1.5,
        title: Row(
          children: [
            const Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              loggedinUser!.email!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _scrollToBottom();
                  },
                  icon: const Icon(
                    Icons.arrow_downward_sharp,
                    size: 18,
                  )),
              IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: ((context) {
                      return const LoginForm();
                    })));
                  },
                  icon: const Icon(
                    Icons.logout,
                    size: 18,
                  )),
            ],
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StreamBuilder(
                stream: FirebaseAPI().getMessage(),
                builder: ((context, snapshot) {
                  List<Widget> messageWidgets = [];
                  if (snapshot.hasData) {
                    isLoading = true;
                    var messages = snapshot.data!.docs;
                    for (var message in messages) {
                      var textMessage = message;

                      final text = textMessage['text'];
                      final sender = textMessage['sender'];

                      var messageWidget = messageBubble(
                          text, sender, loggedinUser!.email == sender);
                      messageWidgets.add(messageWidget);
                    }
                  }

                  return Expanded(
                      child: isLoading
                          ? ListView(
                              controller: _scrollController,
                              shrinkWrap: true,
                              children: messageWidgets)
                          : const Center(
                              child: SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color: Colors.deepPurple,
                                  ))));
                })),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _textController,
                  onChanged: (value) {
                    messageText = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                  ),
                  onSubmitted: ((value) {
                    _sendMessage();
                  }),
                )),
                IconButton(
                    onPressed: () {
                      _sendMessage();
                    },
                    icon: const Icon(
                      Icons.send,
                      size: 18,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget messageBubble(text, sender, isMe) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(
            height: 8,
          ),
          Material(
            color: isMe ? mainColor : const Color.fromARGB(255, 242, 237, 237),
            elevation: 2.5,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Text(
                text,
                style: isMe
                    ? const TextStyle(fontSize: 15, color: Colors.white)
                    : const TextStyle(
                        fontSize: 15,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
