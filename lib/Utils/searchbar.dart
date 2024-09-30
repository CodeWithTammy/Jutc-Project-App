import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onChanged;

  const SearchBarWidget({
    Key? key,
    required this.searchController,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: "Search",
          hintText: "Search by route..",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      ),
    );
  }
}
