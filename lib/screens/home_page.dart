import 'package:flutter/material.dart';
import 'package:flutter_crudjara/models/product.dart';
import 'package:flutter_crudjara/screens/detail_product.dart';
import 'package:flutter_crudjara/screens/edit_page.dart';
import 'package:flutter_crudjara/screens/add_page.dart';
import 'package:flutter_crudjara/screens/login_page.dart';
import 'package:flutter_crudjara/services/api_service.dart';
import 'package:flutter_crudjara/widgets/dashboard_cart.dart';
import '../widgets/product_cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService api = ApiService();
  TextEditingController searchController = TextEditingController();
  List<Product> semuaproduk = [];
  List<Product> hasilpencarian = [];
  String filterHarga = "Semua";
  String sorting = "Nama A-Z";

  Future<void> loadProducts() async {
    try {
      final data = await api.getProducts();
      if (!mounted) return;
      setState(() {
        semuaproduk = data;
        hasilpencarian = List.from(data);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal Mengambil data:$e',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  void prosesData() {
    List<Product> data = List.from(semuaproduk);
    //Pencarian Berdasarkan nama
    final keyword = searchController.text.toLowerCase();
    if (keyword.isNotEmpty) {
      data = data.where((produk) {
        return produk.nama.toLowerCase().contains(keyword);
      }).toList();
    }
    //Filter berdasarkan harga
    if (filterHarga == "Di bawah Rp500000") {
      data = data.where((produk) {
        return produk.harga < 500000;
      }).toList();
    }
    if (filterHarga == "Rp500000-Rp1000000") {
      data = data.where((produk) {
        return produk.harga >= 500000 && produk.harga <= 1000000;
      }).toList();
    }

    if (filterHarga == "Diatas Rp1000000") {
      data = data.where((produk) {
        return produk.harga > 1000000;
      }).toList();
    }
    //sorting (mengurutkan)
    if (sorting == "Nama A-Z") {
      data.sort(
        (a, b) => a.nama.toLowerCase().compareTo(
              b.nama.toLowerCase(),
            ),
      );
    }
    if (sorting == "Nama Z-A") {
      data.sort(
        (a, b) => b.nama.toLowerCase().compareTo(
              a.nama.toLowerCase(),
            ),
      );
    }
    if (sorting == "Harga terendah") {
      data.sort(
        (a, b) => a.harga.compareTo(b.harga),
      );
    }
    if (sorting == "Harga tertinggi") {
      data.sort(
        (a, b) => b.harga.compareTo(a.harga),
      );
    }
    if (sorting == "Stok sedikit") {
      data.sort(
        (a, b) => a.stok.compareTo(b.stok),
      );
    }
    if (sorting == "Stok banyak") {
      data.sort(
        (a, b) => b.stok.compareTo(a.stok),
      );
    }
    //simpan hasil
    setState(() {
      hasilpencarian = data;
    });
  }

  //search
  void cariProduk(String keyword) {
    prosesData();
  }

  //filter harga
  void pilihFilterHarga(String? pilihan) {
    if (pilihan == null) return;
    setState(() {
      filterHarga = pilihan;
    });
    prosesData();
  }

  //sorting
  void pilihSorting(String? pilihan) {
    if (pilihan == null) return;
    setState(() {
      sorting = pilihan;
    });
    prosesData();
  }

  //total stok
  int totalStok() {
    return semuaproduk.fold(
      0,
      (total, item) => total + item.stok,
    );
  }

  //total harga
  int totalNilai() {
    return semuaproduk.fold(
      0,
      (total, item) => total + (item.harga * item.stok),
    );
  }

  //format rupiah
  String formatRupiah(int angka) {
    String hasil = angka.toString();
    String result = '';
    int counter = 0;
    for (int i = hasil.length - 1; i >= 0; i--) {
      result = hasil[i] + result;
      counter++;
      if (counter == 3 && i != 0) {
        result = ".$result";
        counter = 0;
      }
    }
    return "Rp$result";
  }

  Future<void> hapusProduct(Product product) async {
    bool? konfirmasi = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: Text("Apakah yakin ingin manghapus ${product.nama}?"),
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
    if (konfirmasi != true) {
      return;
    }
    if (konfirmasi == true) {
      bool hasil = await api.deleteProduct(product.id!);
      if (!mounted) return;
      if (hasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk berhasil dihapus"),
          ),
        );
        await loadProducts();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Produk gagal dihapus"),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Produk"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await api.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          )
        ],
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6F4E37),
        foregroundColor: Colors.white, //aku tambahin
        onPressed: () async {
          final hasil = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPage(),
            ),
          );
          if (hasil == true) {
            loadProducts();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hallo Admin",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "Selamat Datang di Aplikasi CRUD XII RPL 2",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("Kelola data produk dengan mudah"),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: searchController,
              onSubmitted: cariProduk,
              decoration: InputDecoration(
                hintText: "Cari produk",
                prefixIcon: const Icon(
                  Icons.search,
                ),
                suffixIcon: searchController.text.isEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                        ),
                        onPressed: () {
                          searchController.clear();
                          cariProduk("");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),

            //filter harga
            DropdownButtonFormField<String>(
              value: filterHarga,
              decoration: const InputDecoration(
                labelText: "Filter Harga",
                prefixIcon: Icon(
                  Icons.filter_alt,
                ),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Semua",
                  child: Text(
                    "Semua produk",
                  ),
                ),
                DropdownMenuItem(
                  value: "Di bawah Rp500000",
                  child: Text(
                    "Di bawah Rp500000",
                  ),
                ),
                DropdownMenuItem(
                  value: "Rp500000-Rp1000000",
                  child: Text(
                    "Rp500000-Rp1000000",
                  ),
                ),
                DropdownMenuItem(
                  value: "Diatas Rp1000000",
                  child: Text(
                    "Di atas Rp1000000",
                  ),
                ),
              ],
              onChanged: pilihFilterHarga,
            ),
            const SizedBox(
              height: 15,
            ),

            //sorting
            DropdownButtonFormField<String>(
              value: sorting,
              decoration: const InputDecoration(
                labelText: "Urutkan Produk",
                prefixIcon: Icon(
                  Icons.sort,
                ),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Nama A-Z",
                  child: Text(
                    "Nama A-Z",
                  ),
                ),
                DropdownMenuItem(
                  value: "Nama Z-A",
                  child: Text(
                    "Nama Z-A",
                  ),
                ),
                DropdownMenuItem(
                  value: "Harga terendah",
                  child: Text(
                    "Harga terendah",
                  ),
                ),
                DropdownMenuItem(
                  value: "Harga tertinggi",
                  child: Text(
                    "Harga tertinggi",
                  ),
                ),
                DropdownMenuItem(
                  value: "Stok sedikit",
                  child: Text(
                    "Stok sedikit",
                  ),
                ),
                DropdownMenuItem(
                  value: "Stok banyak",
                  child: Text(
                    "Stok banyak",
                  ),
                ),
              ],
              onChanged: pilihSorting,
            ),
            const SizedBox(
              height: 20,
            ),

            Row(
              children: [
                Expanded(
                  child: DashboardCart(
                    title: "Produk",
                    value: "${semuaproduk.length}",
                    color: Colors.lightBlue,
                    icon: Icons.shopping_bag,
                  ),
                ),
                Expanded(
                  child: DashboardCart(
                    title: "Stok",
                    value: "${totalStok()}",
                    color: Colors.greenAccent,
                    icon: Icons.inventory,
                  ),
                ),
                Expanded(
                  child: DashboardCart(
                    title: "Total Asset",
                    value: formatRupiah(totalNilai()),
                    color: Colors.orangeAccent,
                    icon: Icons.payments,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Daftar produk",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              "${hasilpencarian.length} produk ditemukan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (hasilpencarian.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "Produk tidak ditemukan",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ...hasilpencarian.map((product) {
                return ProductCard(
                  product: product,
                  onEdit: () async {
                    final hasil = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPage(
                          product: product,
                        ),
                      ),
                    );
                    if (hasil == true) {
                      loadProducts();
                    }
                  },
                  onDelete: () {
                    hapusProduct(
                      product,
                    );
                  },
                  onDetail: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailProduct(
                          product: product,
                        ),
                      ),
                    );
                    loadProducts();
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}
