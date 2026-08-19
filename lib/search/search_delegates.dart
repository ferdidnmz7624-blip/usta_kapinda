import 'package:flutter/material.dart';

import '../data/cities.dart';
import '../data/districts.dart';
import '../data/job_categories.dart';

class CategorySearchDelegate extends SearchDelegate<String> {
  static const List<String> categories = JobCategories.all;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = categories.where((e) {
      return e.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.handyman),
          title: Text(filtered[index]),
          onTap: () => close(context, filtered[index]),
        );
      },
    );
  }
}

class CitySearchDelegate extends SearchDelegate<String> {
  static const List<String> cities = Cities.all;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filtered = cities.where((e) {
      return e.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.location_city),
          title: Text(filtered[index]),
          onTap: () => close(context, filtered[index]),
        );
      },
    );
  }
}

class DistrictSearchDelegate extends SearchDelegate<String> {
  final String city;

  DistrictSearchDelegate({
    required this.city,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ""),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final districts = Districts.all[city] ?? [];

    final filtered = districts.where((e) {
      return e.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(filtered[index]),
          onTap: () => close(context, filtered[index]),
        );
      },
    );
  }
}