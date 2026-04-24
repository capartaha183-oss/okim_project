import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';

class ManagePeopleScreen extends StatefulWidget {
  const ManagePeopleScreen({super.key});

  @override
  State<ManagePeopleScreen> createState() => _ManagePeopleScreenState();
}

class _ManagePeopleScreenState extends State<ManagePeopleScreen> {
  final ImagePicker picker = ImagePicker();
  final TextEditingController nameController = TextEditingController();

  List<Map<String, String>> people = [];

  @override
  void initState() {
    super.initState();
    loadPeople();
  }

  Future<void> loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList("people") ?? [];

    setState(() {
      people = data
          .map((item) => Map<String, String>.from(jsonDecode(item)))
          .toList();
    });
  }

  Future<void> savePeople() async {
    final prefs = await SharedPreferences.getInstance();
    final data = people.map((person) => jsonEncode(person)).toList();
    await prefs.setStringList("people", data);
  }

  Future<void> addPerson() async {
    nameController.clear();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return;

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Kişi Ekle"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Kişi adı",
              hintText: "Örn: Taha",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) return;

                people.add({
                  "name": name,
                  "path": image.path,
                });

                await savePeople();
                await loadPeople();

                if (mounted) Navigator.pop(dialogContext);
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deletePerson(int index) async {
    people.removeAt(index);
    await savePeople();
    await loadPeople();
  }

  Widget personCard(Map<String, String> person, int index) {
    final imagePath = person["path"] ?? "";
    final name = person["name"] ?? "İsimsiz";
    final file = File(imagePath);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            backgroundImage: file.existsSync() ? FileImage(file) : null,
            child: file.existsSync()
                ? null
                : const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: () => deletePerson(index),
            icon: const Icon(
              Icons.delete_rounded,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyState() {
    return const Center(
      child: Text(
        "Henüz kayıtlı kişi yok.",
        style: TextStyle(
          color: AppColors.subtitle,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Kayıtlı Kişiler",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addPerson,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          "Kişi Ekle",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: people.isEmpty
            ? emptyState()
            : ListView.builder(
                itemCount: people.length,
                itemBuilder: (context, index) {
                  return personCard(people[index], index);
                },
              ),
      ),
    );
  }
}