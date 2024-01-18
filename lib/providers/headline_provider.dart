import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../model/Headlines.dart';
import 'package:http/http.dart' as http;

   var client = http.Client();
   var BASE_URL = Constants.baseUrl;

  final countryProvider = StateProvider<String>((ref) => 'us');
  final categoryProvider = StateProvider<String>((ref) => 'general');


  final topHeadlinesNewsProvider = FutureProvider<List<Article>>((ref) async {

    final country = ref.watch(countryProvider);
    final category = ref.watch(categoryProvider);

    String finalUrl;
    if (category == null) {
      finalUrl = "";
      finalUrl = '$BASE_URL&country=$country';
    } else {
      finalUrl = "";
      finalUrl = '$BASE_URL&category=$category&country=$country';
    }


    final response = await client.get(Uri.parse(finalUrl));
    // print(finalUrl);

    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      return (jsondata['articles'] as List)
          .map((e) => Article.fromJson(e))
          .toList();
    } else {
      throw Exception(response.reasonPhrase);
    }
  });


