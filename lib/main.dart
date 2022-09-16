import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<http.Response> getEntry() {
    return http.post(
      Uri.parse('https://bionic-reading1.p.rapidapi.com/convert'),
      headers: <String, String>{
        "content-type": "application/x-www-form-urlencoded",
        "X-RapidAPI-Key": "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "X-RapidAPI-Host": "bionic-reading1.p.rapidapi.com"
      },
      body:
          "content=https%3A%2F%2Fplato.stanford.edu%2Fcgi-bin%2Fencyclopedia%2Frandom&response_type=html&request_type=html&fixation=1&saccade=10",
    );
  }

  @override
  void initState() {
    getArticle();
    super.initState();
  }

  void getArticle() {
    setState(() {
      content = "";
    });
    getEntry().then((value) {
      setState(() {
        content = value.body;
      });
      getHuggingFaceSummary(
          content.split("<p class=\"lead\">")[1].split("</p>")[0]);
    });
  }

  void getHuggingFaceSummary(String summary) async {
    var response = await http.post(
      Uri.parse(
          'https://api-inference.huggingface.co/models/facebook/bart-large-cnn'),
      headers: <String, String>{
        "Authorization": "Bearer XXXXXXXXXXXXXXXXXX",
      },
      body: jsonEncode(
        {
          "inputs": summary,
        },
      ),
    );
    getGPTQuestions(jsonDecode(response.body)[0]["summary_text"]);
  }

  void getGPTQuestions(String summary) async {
    var response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: <String, String>{
        "Authorization": "Bearer XXXXXXXXXX",
        "Content-Type": "application/json",
      },
      body: jsonEncode(
        {
          "model": "text-davinci-002",
          "prompt": "$summary\n\nComprehension Questions (3, No Answers):\n 1.",
          "temperature": 0,
          "max_tokens": 50
        },
      ),
    );
    var result = jsonDecode(response.body);
    setState(() {
      questions = ('1. ${result["choices"][0]["text"]}').split("\n");
    });
    print(response.body);
  }

  void jumpToBottom() {
    controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String content = "";
  List<String> questions = [];
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailySEP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Make this dark theme
        brightness: Brightness.dark,
        fontFamily: 'GoogleSans',
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 18.0, height: 1.62),
        ),
      ),
      home: Scaffold(
        body: content == ""
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                controller: controller,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  child: Column(
                    children: [
                      Html(data: content),
                      ElevatedButton(
                          onPressed: getArticle,
                          child: const Text("Next Article")),
                      Text("Questions:",
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                      ...questions.map((question) => Text(question,
                          style: TextStyle(color: Colors.white, fontSize: 18))),
                    ],
                  ),
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: jumpToBottom,
          tooltip: 'Jump to bottom',
          child: const Icon(Icons.arrow_downward),
        ),
      ),
    );
  }
}

// Add question section to the bottom

// Flutter + Dart, RapidAPI, Bionic-Reading API