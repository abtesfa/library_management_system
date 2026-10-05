import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'navigation to new  page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController cont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FIRST PAGE')),
      body: Container(
        margin: EdgeInsets.all(100),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(25.0),
              child: TextField(
                controller: cont,
                decoration: InputDecoration(hintText: 'type any text'),
              ),
            ),
            ElevatedButton(
              child: Text('click'), 
              onPressed: () {
                var route=MaterialPageRoute(
                builder: (BuildContext context) => secondpage(data: cont!.text)
                );
                Navigator.of(context).push(route);
              }),
          ],
        ),
      ),
    );
  }
}

class secondpage extends StatefulWidget {
  final String data;
  secondpage({Key? key, required this.data}) : super(key: key);

  @override
  State<secondpage> createState() => _secondpageState();
}

class _secondpageState extends State<secondpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('second page')),
      body: Container(
        margin: EdgeInsets.all(30),
        padding: EdgeInsets.all(4.0),
        child: Center(
          child: Text(widget.data),
        ),
      ),
    );
  }
}
