import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/";
  Future<List<Product>> getProducts() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    final response = await http.get(
      Uri.parse("${baseUrl}products"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data");
    }
  }

  Future<List<Product>> getProduct() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    final response = await http.get(
      Uri.parse("${baseUrl}products"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data");
    }
  }

  Future<bool> storeProducts(
    Product product,
    File? image,
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${baseUrl}products"),
    );
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });
    request.fields["nama"] = product.nama;
    request.fields["harga"] = product.harga.toString();
    request.fields["stok"] = product.stok.toString();
    request.fields["deskripsi"] = product.deskripsi;

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "gambar",
          image.path,
        ),
      );
    }

    var response = await request.send();
    return response.statusCode == 201;
  }

  Future<bool> updateProduct(Product product) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    final response = await http.put(
      Uri.parse("${baseUrl}products/${product.id}"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {
        "nama": product.nama,
        "harga": product.harga.toString(),
        "stok": product.stok.toString(),
        "deskripsi": product.deskripsi,
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteProduct(int id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    final response = await http.delete(
      Uri.parse("${baseUrl}products/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    return response.statusCode == 200;
  }

  Future<String?> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}login"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["token"];
      }

      return null;
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String token = pref.getString("token") ?? "";
    await http.post(
      Uri.parse("${baseUrl}logout"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    await pref.remove("token");
  }
}
