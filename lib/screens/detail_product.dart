import 'package:flutter/material.dart';
import 'package:flutter_crudjara/models/product.dart';
import 'package:flutter_crudjara/screens/edit_page.dart';

class DetailProduct extends StatelessWidget {
  final Product product;

  const DetailProduct({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white,
        title: const Text("Detail Produk"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Hero(
              tag: product.id!,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: product.gambar == null ||
                          product.gambar!.isEmpty
                      ? Image.asset(
                          "assets/pisang.jpg",
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          "http://127.0.0.1:8000/storage/products/${product.gambar}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/pisang.jpg",
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nama,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(Icons.attach_money),
                        const SizedBox(width: 10),
                        Text(
                          "Rp${product.harga}",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(Icons.inventory),
                        const SizedBox(width: 10),
                        Text(
                          "Stok: ${product.stok}",
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 35),

                    const Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product.deskripsi,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Produk"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  final hasil = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPage(product: product),
                    ),
                  );

                  if (hasil == true) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}