import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/job_categories.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';
import '../data/cities.dart';
import '../data/districts.dart';
import '../search/search_delegates.dart';
import '../generated/app_localizations.dart';

class JobPostPage extends StatefulWidget {
  const JobPostPage({super.key});

  @override
  State<JobPostPage> createState() => _JobPostPageState();
}

class _JobPostPageState extends State<JobPostPage> {
final JobService _jobService = JobService();

bool isLoading = false;

final titleController = TextEditingController();
final descriptionController = TextEditingController();
final cityController = TextEditingController();
final districtController = TextEditingController();
final budgetController = TextEditingController();

final categoryController = TextEditingController();
final startDayController = TextEditingController();

final titleFocus = FocusNode();
final descriptionFocus = FocusNode();
final startDayFocus = FocusNode();

bool titleError = false;
bool categoryError = false;
bool cityError = false;
bool districtError = false;
bool descriptionError = false;
bool startDayError = false;

String selectedCategory = "";

@override
void dispose() {
titleController.dispose();
descriptionController.dispose();
cityController.dispose();
districtController.dispose();
budgetController.dispose();
super.dispose();
startDayController.dispose();

titleFocus.dispose();
descriptionFocus.dispose();
startDayFocus.dispose();
categoryController.dispose();
}

Future<void> publishJob() async {
  final l10n = AppLocalizations.of(context)!;

  setState(() {
    titleError = titleController.text.trim().length < 5;
    descriptionError =
        descriptionController.text.trim().isEmpty;
  });
  if (titleController.text.trim().isEmpty ||
      selectedCategory.isEmpty ||
      descriptionController.text.trim().isEmpty ||
      cityController.text.trim().isEmpty ||
      districtController.text.trim().isEmpty ||
      budgetController.text.trim().isEmpty) {

    startDayController.dispose();

    titleFocus.dispose();
    descriptionFocus.dispose();
    startDayFocus.dispose();
    categoryController.dispose();
  }

  Future<void> publishJob() async {
    setState(() {
      titleError = titleController.text.trim().length < 5;
      descriptionError =
          descriptionController.text.trim().isEmpty;
    });
    if (titleController.text.trim().isEmpty ||
        selectedCategory.isEmpty ||
        descriptionController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        districtController.text.trim().isEmpty ||
        budgetController.text.trim().isEmpty ||
        startDayController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requiredFields),
        ),
      );
      return;
    }

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
  content: Text(l10n.requiredFields),
),
);
return;
}

try {
setState(() {
isLoading = true;
final day =
int.tryParse(startDayController.text.trim());

  startDayError =
  day == null || day < 1 || day > 100;
});

final user = FirebaseAuth.instance.currentUser;

if (user == null) {
  throw Exception(l10n.sessionNotFound);;
}

final doc =
FirebaseFirestore.instance.collection("jobs").doc();

final job = JobModel(
id: doc.id,
userId: user.uid,
title: titleController.text.trim(),
description: descriptionController.text.trim(),
category: selectedCategory,
city: cityController.text.trim(),
district: districtController.text.trim(),
budget:
double.tryParse(budgetController.text.trim()) ?? 0,
  status: "active",
  startAfterDays:
  int.tryParse(startDayController.text.trim()) ?? 1,
createdAt: Timestamp.now(),
);
await _jobService.createJob(job);

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(l10n.listingPublished),
  ),
);

titleController.clear();
descriptionController.clear();
cityController.clear();
districtController.clear();
budgetController.clear();
  startDayController.clear();
setState(() {
  selectedCategory = "";
  categoryController.clear();
});
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(e.toString()),
),
);
} finally {
if (mounted) {
setState(() {
isLoading = false;
});
}
}
}

@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Scaffold(
appBar: AppBar(
  title: Text(l10n.postJob),
centerTitle: true,
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
  Text(
    l10n.newJobListing,
    style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 20),

  TextField(
    controller: titleController,
    focusNode: titleFocus,
    maxLength: 50,
    onChanged: (value) {
      setState(() {
        titleError = value.trim().length < 5;
      });
    },
    decoration: InputDecoration(
        labelText: l10n.jobTitle,
      hintText: l10n.jobTitleHint,
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.title),
      counterText: "${titleController.text.length}/50",
      errorText: titleError
          ? l10n.jobTitleLengthError
          : null,
    ),
  ),

const SizedBox(height: 16),

  TextField(
    controller: categoryController,
    readOnly: true,
    decoration: InputDecoration(
      labelText: l10n.category,
      hintText: l10n.selectCategoryHint,
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.search),
      suffixIcon: Icon(Icons.arrow_drop_down),
    ),
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CategorySearchDelegate(),
      );

      if (result != null) {
        setState(() {
          selectedCategory = result;
          categoryController.text = result;
        });
      }
    },
  ),

const SizedBox(height: 16),

  TextField(
    controller: cityController,
    readOnly: true,
    decoration:InputDecoration(
      labelText: l10n.city,
      hintText: l10n.selectCityHint,
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.location_city),
      suffixIcon: Icon(Icons.arrow_drop_down),
    ),
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CitySearchDelegate(),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          cityController.text = result;
          districtController.clear();
        });
      }
    },
  ),

const SizedBox(height: 16),



const SizedBox(height: 16),

  TextField(
    controller: districtController,
    readOnly: true,
    decoration:InputDecoration(
      labelText: l10n.district,
      hintText: l10n.selectDistrictHint,
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.map),
      suffixIcon: Icon(Icons.arrow_drop_down),
    ),
    onTap: () async {
      if (cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.selectCityFirst),
          ),
        );
        return;
      }

      final result = await showSearch<String>(
        context: context,
        delegate: DistrictSearchDelegate(
          city: cityController.text,
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          districtController.text = result;
        });
      }
    },
  ),
  const SizedBox(height: 16),

  TextField(
    controller: startDayController,
    focusNode: startDayFocus,
    keyboardType: TextInputType.number,
    maxLength: 3,
    onChanged: (value) {
      final day = int.tryParse(value);

      setState(() {
        startDayError =
            day == null || day < 1 || day > 100;
      });
    },
    decoration: InputDecoration(
      labelText: l10n.startJobWhen,
      hintText: l10n.daysRange,
      border: const OutlineInputBorder(),
      prefixIcon: const Icon(Icons.schedule),
      counterText:
      "${startDayController.text.length}/3",
      errorText: startDayError
          ? l10n.daysRangeError
          : null,
    ),
  ),
  TextField(
    controller: descriptionController,
    focusNode: descriptionFocus,
    maxLines: 5,
    maxLength: 500,
    onChanged: (value) {
      setState(() {
        descriptionError = value.trim().isEmpty;
      });
    },
    decoration: InputDecoration(
      labelText: l10n.jobDetails,
      hintText: l10n.jobDetailsHint,
      border: const OutlineInputBorder(),
      alignLabelWithHint: true,
      prefixIcon: const Icon(Icons.description),
      counterText:
      "${descriptionController.text.length}/500",
      errorText: descriptionError
          ? l10n.enterJobDetails
          : null,
    ),
  ),

  const SizedBox(height: 16),
const SizedBox(height: 16),

TextField(
controller: budgetController,
keyboardType: TextInputType.number,
decoration: InputDecoration(
  labelText: l10n.budget,
border: OutlineInputBorder(),
prefixIcon: Icon(Icons.payments),
),
),

const SizedBox(height: 24),

SizedBox(
height: 55,
child: ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.orange,
    foregroundColor: Colors.white,
  ),
onPressed: isLoading ? null : publishJob,
icon: isLoading
? const SizedBox(
width: 22,
height: 22,
child: CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
: const Icon(Icons.publish),
label: Text(
isLoading
    ? l10n.publishing
    : l10n.publishListing,
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
),
),
  const SizedBox(height: 30),

  Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.listingInfo,
            ),
          ),
        ],
      ),
    ),
  ),

  const SizedBox(height: 20),
],
),
),
);
}
}
