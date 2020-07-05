import 'package:flutter/material.dart';
import 'package:internship_chat/chat.dart';
import 'package:internship_chat/chatScreen.dart';
import 'package:internship_chat/constants.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'chat_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE chats(id INTEGER PRIMARY KEY, name TEXT, messages TEXT)",
      );
    },
    version: 1,
  );

  DatabaseBrain databaseBrain = DatabaseBrain(database: database);

  runApp(MyApp(
    databaseBrain: databaseBrain,
  ));
}

class MyApp extends StatelessWidget {
  final DatabaseBrain databaseBrain;

  const MyApp({Key key, this.databaseBrain}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Internship Chat',
      theme: ThemeData.dark(),
      home: Home(
        databaseBrain: databaseBrain,
      ),
    );
  }
}

class Home extends StatefulWidget {
  final DatabaseBrain databaseBrain;

  const Home({Key key, @required this.databaseBrain}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Chat> chats = [];
  createStartingDatabase() async {
    await widget.databaseBrain
        .insertChat(Chat(id: 1, name: 'Su Mit', messages: ['Hi', 'Hello']));
    await widget.databaseBrain.insertChat(
        Chat(id: 2, name: 'Goku', messages: ['Su Mit is pro', 'Goku']));
    await widget.databaseBrain
        .insertChat(Chat(id: 3, name: 'Ben', messages: ['Hi! there', 'Bye ']));
    await widget.databaseBrain.insertChat(
        Chat(id: 3, name: 'Black', messages: ['Good Morning', 'Good Night ']));
  }

  @override
  void initState() {
    widget.databaseBrain.getChats().then((value) {
      if (value.length < 1)
        createStartingDatabase();
      else
        chats = value;
      setState(() {
        print('Database Loaded');
      });
    });
    super.initState();
  }

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
                'Messages (${chats.length})',
                style: kHeadingTextStyle,
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return ChatListTile(
                      name: chats[index].name,
                      lastMessage: chats[index].messages.last,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                  chat: chats[index],
                                  databaseBrain: widget.databaseBrain,
                                )),
                      ).then((value) {
                        setState(() {});
                      }),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListTile extends StatelessWidget {
  final void Function() onTap;
  final String name, lastMessage;

  const ChatListTile({Key key, this.onTap, this.name, this.lastMessage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(),
        title: Text(name),
        subtitle: Text(lastMessage),
        trailing: Text('Jul 8'),
      ),
    );
  }
}
