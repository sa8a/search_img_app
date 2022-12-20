import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PixabayPage(),
    );
  }
}

class PixabayPage extends StatefulWidget {
  const PixabayPage({super.key});

  @override
  State<PixabayPage> createState() => _PixabayPageState();
}

class _PixabayPageState extends State<PixabayPage> {
  List hits = [];

  Future<void> fetchImages() async {
    Response response = await Dio().get(
        'https://pixabay.com/api/?key=$Pixabay_API_KEY&q=yellow+flowers&image_type=photo');
    hits = response.data['hits'];
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 横に何個表示するか？
        ),
        itemCount: hits.length, // 最大要素数
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> hit = hits[index];
          return Image.network(hit['previewURL']);
        },
      ),
    );
  }
}
