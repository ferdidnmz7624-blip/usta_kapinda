import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../pages/job_detail_page.dart';
import '../services/job_service.dart';
import '../data/cities.dart';
import '../data/districts.dart';
import '../data/job_categories.dart';
import '../search/search_delegates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../generated/app_localizations.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final UserService _userService = UserService();

  UserModel? currentUser;

  bool loadingUser = true;
final JobService _jobService = JobService();
final TextEditingController cityController =
TextEditingController();

final TextEditingController districtController =
TextEditingController();

final TextEditingController categoryController =
TextEditingController();

String selectedCity = "Tümü";
String selectedDistrict = "Tümü";
String selectedCategory = "Tümü";

final TextEditingController searchController =
TextEditingController();

final List<String> cities = [
"Tümü",
"Antalya",
"İstanbul",
"Ankara",
"İzmir",
];

final List<String> districts = [
"Tümü",
"Kepez",
"Muratpaşa",
"Konyaaltı",
"Döşemealtı",
];

final List<String> categories = [
"Tümü",
"Su Tesisatı",
"Elektrik",
"Klima",
"Boya",
"Mobilya",
"Temizlik",
"İnşaat",
"Çatı",
];
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      setState(() {
        loadingUser = false;
      });
      return;
    }

    currentUser = await _userService.getUser(authUser.uid);

    if (mounted) {
      setState(() {
        loadingUser = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (loadingUser) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
appBar: AppBar(
  title: Text(l10n.latestListings),
centerTitle: true,
),
body: Column(
children: [
Padding(
padding: const EdgeInsets.all(15),
child: Column(
children: [
  TextField(
    controller: cityController,
    readOnly: true,
decoration: InputDecoration(
labelText: l10n.city,
prefixIcon: const Icon(Icons.location_city),
suffixIcon: const Icon(Icons.arrow_drop_down),
border: const OutlineInputBorder(),
),
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CitySearchDelegate(),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          selectedCity = result;
          cityController.text = result;

          selectedDistrict = "Tümü";
          districtController.clear();
        });
      }
    },
  ),

  const SizedBox(height: 10),

  TextField(
    controller: districtController,
    readOnly: true,
decoration: InputDecoration(
labelText: l10n.district,
prefixIcon: const Icon(Icons.map),
suffixIcon: const Icon(Icons.arrow_drop_down),
border: const OutlineInputBorder(),
),
    onTap: () async {
      if (selectedCity == "Tümü" || selectedCity.isEmpty) {
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
          city: selectedCity,
        ),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          selectedDistrict = result;
          districtController.text = result;
        });
      }
    },
  ),

  const SizedBox(height: 10),

  TextField(
    controller: categoryController,
    readOnly: true,
decoration: InputDecoration(
labelText: l10n.professions,
prefixIcon: const Icon(Icons.handyman),
suffixIcon: const Icon(Icons.arrow_drop_down),
border: const OutlineInputBorder(),
),
    onTap: () async {
      final result = await showSearch<String>(
        context: context,
        delegate: CategorySearchDelegate(),
      );

      if (result != null && result.isNotEmpty) {
        setState(() {
          selectedCategory = result;
          categoryController.text = result;
        });
      }
    },
  ),

const SizedBox(height: 10),

TextField(
controller: searchController,
decoration: InputDecoration(
hintText: l10n.searchListings,
prefixIcon: const Icon(Icons.search),
border: const OutlineInputBorder(),
),
onChanged: (_) {
setState(() {});
},
),
],
),
),

Expanded(
child: StreamBuilder<List<JobModel>>(
  stream: currentUser?.activeMode == "craftsman"
      ? _jobService.getJobsForCraftsman(
    city: currentUser!.city,
    professions: currentUser!.professions,
  )
      : _jobService.getJobs(),
builder: (context, snapshot) {
if (snapshot.connectionState ==
ConnectionState.waiting) {
return const Center(
child: CircularProgressIndicator(),
);
}

if (snapshot.hasError) {
return Center(
child: Text("${l10n.error}: ${snapshot.error}"),
);
}

final jobs = (snapshot.data ?? []).where((job) {
  final cityOk =
      selectedCity == "Tümü" || job.city == selectedCity;

  final districtOk =
      selectedDistrict == "Tümü" ||
          job.district == selectedDistrict;

  final categoryOk =
      selectedCategory == "Tümü" ||
          job.category == selectedCategory;

  final searchOk = searchController.text.isEmpty ||
      job.title
          .toLowerCase()
          .contains(searchController.text.toLowerCase()) ||
      job.description
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

  return cityOk &&
      districtOk &&
      categoryOk &&
      searchOk;
}).toList();
if (jobs.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.search_off,
          size: 70,
          color: Colors.grey,
        ),
        const SizedBox(height: 15),
        Text(
          l10n.noListingsMatchFilters,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.changeFiltersAndTryAgain,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
return ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: jobs.length,
itemBuilder: (context, index) {
final job = jobs[index];

return Card(
margin: const EdgeInsets.only(bottom: 16),
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
job.title,
style: const TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 10),

Text(job.description),

const SizedBox(height: 15),

Wrap(
spacing: 8,
runSpacing: 8,
children: [
Chip(
avatar: const Icon(
Icons.category,
size: 18,
),
label: Text(job.category),
),
Chip(
avatar: const Icon(
Icons.location_city,
size: 18,
),
label: Text(job.city),
),
Chip(
avatar: const Icon(
Icons.map,
size: 18,
),
label: Text(job.district),
),
],
),

const SizedBox(height: 15),

Row(
mainAxisAlignment:
MainAxisAlignment.spaceBetween,
children: [
Text(
"₺${job.budget.toStringAsFixed(0)}",
style: const TextStyle(
fontSize: 22,
color: Colors.green,
fontWeight:
FontWeight.bold,
),
),
  Chip(
    backgroundColor: Colors.green.shade100,
    avatar: const Icon(
      Icons.check_circle,
      color: Colors.green,
      size: 18,
    ),
label: Text(
l10n.published,
style: const TextStyle(
color: Colors.green,
fontWeight: FontWeight.bold,
),
),
  ),
],
),

  const SizedBox(height: 15),

  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.visibility),
label: Text(l10n.viewListing),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                JobDetailPage(job: job),
          ),
        );
      },
    ),
  ),
],
),
),
);
},
);
},
),
),
],
),
);
}
}
