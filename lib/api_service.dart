import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final List<String> urls = [
    'https://restcountries.com/v3.1/translation/germany',
    'https://restcountries.com/v3.1/translation/india',
    'https://restcountries.com/v3.1/translation/israel',
    'https://restcountries.com/v3.1/translation/lanka',
    'https://restcountries.com/v3.1/translation/italy',
    'https://restcountries.com/v3.1/translation/china',
    'https://restcountries.com/v3.1/translation/korea'
  ];

  Future<List<Map<String, dynamic>>> fetchAllCountriesData() async {
    List<Map<String, dynamic>> countryDataList = [];

    for (String url in urls) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body)[0];
        Map<String, dynamic> countryData = {
          'commonName': data['name']['common'],
          'officialName': data['name']['official'],
          'currency': data['currencies']?.values?.first['name'] ?? 'No currency info',
          'flagUrl': data['flags']['png'],
          'region': data['region'],  // Fetch region data
        };
        countryDataList.add(countryData);
      } else {
        throw Exception('Failed to load country data');
      }
    }

    return countryDataList;
  }
}
