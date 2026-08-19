import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminSupportDetailPage extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const AdminSupportDetailPage({
    super.key,
    required this.documentId,
    required this.data,
  });

  @override
  State<AdminSupportDetailPage> createState() =>
      _AdminSupportDetailPageState();
}

class _AdminSupportDetailPageState
    extends State<AdminSupportDetailPage> {
  final TextEditingController replyController =
  TextEditingController();

  bool loading = false;

  Future<void> sendReply() async {
    if (replyController.text.trim().isEmpty) return;

    setState(() {
      loading = true;
    });

    await FirebaseFirestore.instance
        .collection("support_requests")
        .doc(widget.documentId)
        .update({
      "adminReply": replyController.text.trim(),
      "status": "answered",
      "replyDate": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
      "isRead": true,
    });

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cevap gönderildi."),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Destek Talebi"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data["subject"] ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Gönderen: ${data["firstName"]} ${data["lastName"]}",
            ),

            Text(
              "E-posta: ${data["email"]}",
            ),

            const SizedBox(height: 20),

            const Text(
              "Açıklama",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(data["description"] ?? ""),

            const SizedBox(height: 25),

            TextField(
              controller: replyController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Admin cevabı",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : sendReply,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Cevabı Gönder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}