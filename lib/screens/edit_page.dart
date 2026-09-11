import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_crudjara/models/product.dart';
import 'package:flutter_crudjara/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final Product product;

  const EditPage({
    super.key,
    required this.product,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  final stokController = TextEditingController();
  final deskripsiController = TextEditingController();

  final ApiService api = ApiService();
  final ImagePicker picker = ImagePicker();

  bool loading = false;

  File? image;

  @override
  void initState() {
    super.initState();

    namaController.text = widget.product.nama;
    hargaController.text = widget.product.harga.toString();
    stokController.text = widget.product.stok.toString();
    deskripsiController.text = widget.product.deskripsi;
  }

  Future<void> pilihGambar() async {
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future<void> updateData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    Product product = Product(
      id: widget.product.id,
      nama: namaController.text,
      harga: int.parse(hargaController.text),
      stok: int.parse(stokController.text),
      deskripsi: deskripsiController.text,
      gambar: widget.product.gambar,
    );

    bool berhasil = await api.updateProduct(
      product,
    );

    setState(() {
      loading = false;
    });

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil diupdate"),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk gagal diupdate"),
        ),
      );
    }
  }

  Future<void> konfirmasiUpdate() async {
    bool? hasil = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text(
            "Apakah data akan diperbarui?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Ya"),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      updateData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Produk"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: pilihGambar,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: image != null
                        ? Image.file(
                            image!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            "http://127.0.0.1:8000/storage/products/${widget.product.gambar}",
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: 150,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  "Klik gambar untuk mengganti",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: "Nama Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Nama produk wajib diisi";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: "Harga Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga produk wajib diisi";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: stokController,
                decoration: const InputDecoration(
                  labelText: "Stok Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Stok produk wajib diisi";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: deskripsiController,
                decoration: const InputDecoration(
                  labelText: "Deskripsi Produk",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Deskripsi produk wajib diisi";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : konfirmasiUpdate,
                  icon: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.edit),
                  label: Text(
                    loading ? "mengubah.." : "UPDATE",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
