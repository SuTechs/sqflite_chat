import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_4.dart';
import 'package:internship_chat/chat.dart';
import 'package:internship_chat/constants.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;
  final DatabaseBrain databaseBrain;

  const ChatScreen({Key key, this.chat, this.databaseBrain}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Conversation with\nSu Mit',
                style: kHeadingTextStyle,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.chat.messages.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10),
                      child: ChatBubble(
                        backGroundColor: const Color(0x384955),
                        alignment: Alignment.centerRight,
                        clipper: ChatBubbleClipper4(
                          type: BubbleType.sendBubble,
                        ),
                        child: Text(widget.chat.messages[index]),
                      ),
                    );
                  }),
            ),
            CustomTextField(
              onSend: (value) {
                setState(() {
                  widget.chat.messages.add(value);
                  widget.databaseBrain.updateChat(widget.chat);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final void Function(String) onSend;

  const CustomTextField({Key key, this.onSend}) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isSendText = false;
  String message;

  final _controller = TextEditingController();
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              maxLength: null,
              focusNode: myFocusNode,
              controller: _controller,
              onChanged: (p) {
                setState(() {
                  if (p.trim().length > 0) {
                    isSendText = true;
                    message = p;
                  } else if (p.trim().length < 1) {
                    isSendText = false;
                  }
                });
              },
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Say Something...',
                hintStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.black,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(color: Color(0xff707070), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  borderSide: BorderSide(color: Color(0xff707070)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Visibility(
            visible: isSendText,
            child: FloatingActionButton(
              elevation: 0,
              heroTag: 'sendText',
              child: Icon(
                Icons.send,
                size: 42,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              onPressed: () {
                setState(() {
                  isSendText = false;
                  if (message != null) {
                    widget.onSend(message);
                    _controller.clear();
                    myFocusNode.unfocus();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
