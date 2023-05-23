import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  Box? box;
  RxList<int> data = <int>[].obs;

  @override
  void initState() {
    // TODO: implement initState

    _init();
    super.initState();
  }

  Future<void> _init() async {
    box = await Hive.openBox("data");

    if (box!.isOpen && box!.isNotEmpty) {
      for (var i = 0; i < box!.length; i++) {
        int n = box!.getAt(i);
        data.add(n);
      }
    }
  }

  @override
  void dispose() {
    if (box != null) {
      box!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Hive",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () {
              return Visibility(
                visible: data.isNotEmpty,
                child: IconButton(
                  onPressed: () {
                    deleteAll();
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (data.isEmpty) {
            return const Center(
              child: Text("Empty"),
            );
          }
          return ListView.separated(
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data[index].toString(),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        update(index: index);
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        delete(index: index);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1,
                color: Colors.grey.shade300,
              );
            },
            itemCount: data.length,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          add();
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }

  void add() async {
    int number = Random().nextInt(100);
    if (!box!.isOpen) {
      await _init();
    }

    await box!.add(number);

    if (box!.isNotEmpty) {
      List<int> numbers = [];
      for (var i = 0; i < box!.length; i++) {
        int n = box!.getAt(i);
        numbers.add(n);
      }
      data.value = numbers;
    }
  }

  void update({required int index}) async {
    if (!box!.isOpen) {
      await _init();
    }

    int n = await box!.getAt(index);
    n = n + 1;
    await box!.putAt(index, n);
    data[index] = n;
  }

  void delete({required int index}) async {
    if (!box!.isOpen) {
      await _init();
    }

    await box!.deleteAt(index);
    data.removeAt(index);
  }

  void deleteAll() async {
    if (!box!.isOpen) {
      await _init();
    }

    await box!.deleteFromDisk();
    data.clear();
  }
}
