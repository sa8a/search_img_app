import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  List<PixabayImage> pixabayImages = [];

  // APIを通して画像を取得する
  Future<void> fetchImages(String text) async {
    final response = await Dio().get(
        'https://pixabay.com/api/?key=$Pixabay_API_KEY&q=$text&image_type=photo&per_page=100');
    // キャスト：List型と認識させる（以下の書き方でもOK）
    // final hits = response.data['hits'] as List;
    final List hits = response.data['hits'];
    pixabayImages = hits.map(
      (e) {
        return PixabayImage.fromMap(e);
      },
    ).toList();
    setState(() {});
  }

  // 画像をシェアする
  Future<void> shareImage(String url) async {
    // 1. URLから画像をダウンロード
    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    // 2. ダウンロードしたデータをファイルに保存
    final dir = await getTemporaryDirectory();
    final file =
        await File('${dir.path}/image.png').writeAsBytes(response.data);

    // 3. Shareパッケージを呼び出して共有
    Share.shareFiles([file.path]);
  }

  @override
  void initState() {
    super.initState();
    fetchImages('花');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: '花',
          decoration: const InputDecoration(
            fillColor: Colors.white,
            filled: true,
          ),
          onFieldSubmitted: (text) {
            fetchImages(text);
          },
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 横に何個表示するか？
        ),
        itemCount: pixabayImages.length, // 最大要素数
        itemBuilder: (BuildContext context, int index) {
          final pixabayImage = pixabayImages[index];
          return InkWell(
            onTap: () async {
              shareImage(pixabayImage.webformatURL);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  pixabayImage.previewURL,
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.thumb_up_alt,
                          size: 14,
                        ),
                        Text(pixabayImage.likes.toString()),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class PixabayImage {
  final String webformatURL;
  final String previewURL;
  final int likes;

  // 名前無しコンストラクタ（順番など変わると困る）
  // PixabayImage({this.webformatURL, this.previewURL, this.likes});

  // 名前付きコンストラクタ（順番など変得てもエラーにならない、keyがあるので可読性が上がる）
  PixabayImage({
    required this.webformatURL,
    required this.previewURL,
    required this.likes,
  });

  // mapを受け取って、PixabayImageのインスタンスを作る
  factory PixabayImage.fromMap(Map<String, dynamic> map) {
    return PixabayImage(
      webformatURL: map['webformatURL'],
      previewURL: map['previewURL'],
      likes: map['likes'],
    );
  }
}
