import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_editor_plus/data/image_item.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_editor_plus/options.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;
  final loading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.small(
          onPressed: _addImage,
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return Future.value();
          },
          child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasData == false || snapshot.data == null) {
                return const Center(
                  child: Text('No data'),
                );
              }
              user ??= snapshot.requireData;

              return StreamBuilder(
                  stream: firestore
                      .collection('images')
                      .doc(snapshot.requireData?.uid ?? '')
                      .snapshots(
                        includeMetadataChanges: true,
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }

                    final fields = snapshot.requireData;
                    final keys = fields.data()?.keys.toList() ?? [];
                    return GridView.builder(
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        final key = keys[index];
                        final url = fields.data()?[key] ?? '';
                        return GestureDetector(
                          onTap: () async {
                            _itemtapped(url,fields);
                          },
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 10,
                      ),
                    );
                  });
            },
          ),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: loading,
        builder: (context, value, child) {
          return Visibility(
            visible: value,
            child: child!,
          );
        },
        child: Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            color: Colors.black38,
            child: const CircularProgressIndicator.adaptive(),
          ),
        ),
      )
    ]);
  }

  _mapDocsToImageItem(
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
  ) {
    return snapshot.data?.docs.map(
      (e) {
        return e.get('image');
      },
    );
  }

  void _addImage({
    String? url,
  }) async {
    final images = await context.pushNamed<List<ImageItem>>(
      'image_editor',
    );
    if (images == null) return;

    for (final image in images) {
      final now = DateTime.now();
      final snapshot = await storage
          .ref(
            now.toIso8601String(),
          )
          .putData(
            image.bytes,
          );
      final url = await snapshot.ref.getDownloadURL();
      await firestore
          .collection(
            'images',
          )
          .doc(user?.uid ?? '')
          .set(
        {
          now.toIso8601String(): url,
        },
      );
    }
  }

  void _itemtapped(String url, DocumentSnapshot<Map<String, dynamic>> fields) async {
    try {
      loading.value = true;
      final ref = storage.refFromURL(url);
      final data = await ref.getData();
      if (data != null && context.mounted) {
        final image = await context.pushNamed<Uint8List>(
          'image_editor',
          extra: data,
        );
        if (image != null) {
          await ref.putData(image);

        }
      }
    } catch (e) {
      print(e);
    } finally {
      loading.value = false;
    }
  }
}
