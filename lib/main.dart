import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'api_service.dart';

void main() {
  runApp(LocationInfoApp());
}

class LocationInfoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Info App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: CountryListScreen(),
    );
  }
}

class CountryListScreen extends StatefulWidget {
  @override
  _CountryListScreenState createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> countriesData;
  List<Map<String, dynamic>> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    countriesData = apiService.fetchAllCountriesData();
    countriesData.then((data) {
      setState(() {
        filteredCountries = data;
      });
    });
  }

  // Function to sort countries alphabetically
  void _sortAlphabetically() {
    setState(() {
      filteredCountries.sort((a, b) => a['commonName'].compareTo(b['commonName']));
    });
  }

  // Function to filter countries by region
  void _filterByRegion(String region) {
    setState(() {
      filteredCountries = filteredCountries.where((country) => country['region'] == region).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Countries Info'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Alphabetically') {
                _sortAlphabetically();
              } else {
                _filterByRegion(value);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Alphabetically',
                child: Text('Sort Alphabetically'),
              ),
              PopupMenuItem(
                value: 'Asia',
                child: Text('Filter by Asia'),
              ),
              PopupMenuItem(
                value: 'Europe',
                child: Text('Filter by Europe'),
              ),
              PopupMenuItem(
                value: 'Africa',
                child: Text('Filter by Africa'),
              ),
              PopupMenuItem(
                value: 'Americas',
                child: Text('Filter by Americas'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: countriesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return ListView.builder(
            itemCount: filteredCountries.length,
            itemBuilder: (context, index) {
              final country = filteredCountries[index];
              return CountryInfoCard(
                commonName: country['commonName'],
                officialName: country['officialName'],
                currencyName: country['currency'],
                flagUrl: country['flagUrl'],
              );
            },
          );
        },
      ),
    );
  }
}

class CountryInfoCard extends StatelessWidget {
  final String commonName;
  final String officialName;
  final String currencyName;
  final String flagUrl;

  CountryInfoCard({
    required this.commonName,
    required this.officialName,
    required this.currencyName,
    required this.flagUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: flagUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        title: Text('$commonName ($officialName)'),
        subtitle: Text('Currency: $currencyName'),
      ),
    );
  }
}
