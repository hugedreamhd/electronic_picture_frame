import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyGalleryApp(),
    );
  }
}

class MyGalleryApp extends StatefulWidget {
  const MyGalleryApp({super.key});

  @override
  State<MyGalleryApp> createState() => _MyGalleryAppState();
}

//사진 선택 슬라이드
class _MyGalleryAppState extends State<MyGalleryApp> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? images;

  int currentPage = 0; //현재 페이지 기억
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    images = await _picker.pickMultiImage();

    if (images != null) {
      Timer.periodic(const Duration(seconds: 5), (timer) {
        currentPage++;

        if (currentPage > images!.length - 1) {
          currentPage = 0;
        }

        pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.linear,
        );
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('전자액자'),
      ),
      body: images == null
          ? Center(child: Text('No data'))
          : PageView(
              controller: pageController, //컨트롤러 통해 페이지뷰 조작
              children: images!.map((image) {
                return FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      final data = snapshot.data;

                      if (data == null ||
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Image.memory(
                        data,
                        width: double.infinity,
                      );
                    });
              }).toList(), //삼항연산을 쓰게 되면 널이 아님을 보증하는 ! 필요
            ),
    );
  }
}
