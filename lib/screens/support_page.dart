import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../generated/app_localizations.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
final _formKey = GlobalKey<FormState>();

final TextEditingController firstNameController =
TextEditingController();

final TextEditingController lastNameController =
TextEditingController();

final TextEditingController emailController =
TextEditingController();

final TextEditingController descriptionController =
TextEditingController();

final ImagePicker picker = ImagePicker();

File? selectedImage;

bool isLoading = false;

String? selectedSubject;


@override
void initState() {
super.initState();

emailController.text =
FirebaseAuth.instance.currentUser?.email ?? "";
}

Future pickImage() async {
  final l10n = AppLocalizations.of(context)!;
final XFile? image = await picker.pickImage(
source: ImageSource.gallery,
imageQuality: 80,
);

if (image == null) return;

final file = File(image.path);

final size = await file.length();

if (size > 5 * 1024 * 1024) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.screenshotTooLarge),
    ),
  );

  return;
}

setState(() {
  selectedImage = file;
});
}

Future<String?> uploadImage() async {
if (selectedImage == null) return null;

final uid = FirebaseAuth.instance.currentUser!.uid;

final ref = FirebaseStorage.instance
.ref()
.child("support_images")
.child(uid)
.child(
"${DateTime.now().millisecondsSinceEpoch}.jpg");

await ref.putFile(selectedImage!);

return await ref.getDownloadURL();
}

Future sendSupportRequest() async {
  final l10n = AppLocalizations.of(context)!;
  FocusScope.of(context).unfocus();
  if (selectedSubject == null) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.selectSubject),
      ),
    );
    return;
  }

setState(() {
isLoading = true;
});

try {
final imageUrl = await uploadImage();

await FirebaseFirestore.instance
    .collection("support_requests")
    .add({
  "uid": FirebaseAuth.instance.currentUser!.uid,

  "firstName": firstNameController.text.trim(),

  "lastName": lastNameController.text.trim(),

  "email": emailController.text.trim(),

  "subject": selectedSubject,

  "description": descriptionController.text.trim(),

  "imageUrl": imageUrl,
  "ticketNo":
  "DK-${DateTime.now().millisecondsSinceEpoch}",
  "status": "open",

  "isRead": false,

  "adminReply": "",

  "replyDate": null,

  "createdAt": Timestamp.now(),

  "updatedAt": Timestamp.now(),

  "app": "Usta Kapında",
});

if (!mounted) return;

showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            l10n.supportRequestCreated,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            l10n.supportRequestSent,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ),
        ],
      ),
    );
  },
);

firstNameController.clear();
lastNameController.clear();
descriptionController.clear();

setState(() {
selectedImage = null;
selectedSubject = null;
});
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
  content: Text(
    "${l10n.errorOccurred}\n$e",
  ),
),
);
}

setState(() {
isLoading = false;
});
}

InputDecoration inputDecoration(
String text,
IconData icon,
) {
return InputDecoration(
labelText: text,
prefixIcon: Icon(icon),
border: OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
),
focusedBorder: OutlineInputBorder(
borderRadius:
BorderRadius.circular(15),
),
);
}

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final subjects = [
    l10n.accountIssue,
    l10n.offerIssue,
    l10n.chatIssue,
    l10n.technicalIssue,
    l10n.complaint,
    l10n.suggestion,
    l10n.accountSuspended,
    l10n.appCrashes,
    l10n.other,
  ];

return Scaffold(

appBar: AppBar(
  title: Text(l10n.supportCenter),
centerTitle: true,
),
body: SafeArea(
child: Form(
key: _formKey,
child: SingleChildScrollView(
padding:
const EdgeInsets.all(18),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
  Text(
    l10n.howCanWeHelp,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  ),

const SizedBox(height: 8),

  Text(l10n.supportDescription),

const SizedBox(height: 30),
TextFormField(
controller: firstNameController,
  decoration: inputDecoration(
    l10n.firstName,
    Icons.person,
  ),
validator: (value) {
if (value == null || value.trim().isEmpty) {
  return l10n.firstNameRequired;
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: lastNameController,
  decoration: inputDecoration(
    l10n.lastName,
    Icons.badge,
  ),
validator: (value) {
if (value == null || value.trim().isEmpty) {
  return l10n.lastNameRequired;
}
return null;
},
),

const SizedBox(height: 18),

TextFormField(
controller: emailController,
keyboardType: TextInputType.emailAddress,
  decoration: inputDecoration(
    l10n.email,
    Icons.email,
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }

    final email = value.trim();

    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email)) {
      return l10n.invalidEmail;
    }

    return null;
  },
),

const SizedBox(height: 18),

  DropdownButtonFormField<String>(
value: selectedSubject,
  decoration: inputDecoration(
    l10n.subject,
    Icons.help_outline,
  ),
    items: subjects.map<DropdownMenuItem<String>>((String subject) {
      return DropdownMenuItem<String>(
        value: subject,
        child: Text(subject),
      );
    }).toList(),
    onChanged: (String? value) {
      setState(() {
        selectedSubject = value;
      });
    },
),

const SizedBox(height: 18),

TextFormField(
controller: descriptionController,
maxLines: 6,
  decoration: inputDecoration(
    l10n.description,
    Icons.description,
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.descriptionRequired;
    }

    if (value.trim().length < 10) {
      return l10n.descriptionTooShort;
    }

    return null;
  },
),

const SizedBox(height: 25),

  Text(
    l10n.screenshotOptional,
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
  ),

const SizedBox(height: 12),

InkWell(
onTap: pickImage,
borderRadius: BorderRadius.circular(15),
child: Container(
width: double.infinity,
height: 170,
decoration: BoxDecoration(
color: Colors.grey.shade100,
borderRadius: BorderRadius.circular(15),
border: Border.all(
color: Colors.grey.shade400,
),
),
child: selectedImage == null
? Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.add_a_photo,
size: 45,
color: Colors.grey,
),
SizedBox(height: 10),
  Text(
    l10n.chooseScreenshot,
  ),
],
)
    : Stack(
  children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.file(
        selectedImage!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
    Positioned(
      top: 8,
      right: 8,
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        child: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () {
            setState(() {
              selectedImage = null;
            });
          },
        ),
      ),
    ),
  ],
),
),
),

const SizedBox(height: 35),

SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton.icon(
onPressed:
isLoading ? null : sendSupportRequest,
icon: isLoading
? const SizedBox(
height: 22,
width: 22,
child:
CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
: const Icon(Icons.send),
  label: Text(
    isLoading
        ? l10n.sending
        : l10n.sendSupportRequest,
  ),
),
),

const SizedBox(height: 40),
],
),
),
),
),
);
}

@override
void dispose() {
  firstNameController.dispose();
  lastNameController.dispose();
  emailController.dispose();
  descriptionController.dispose();
  super.dispose();
}
}