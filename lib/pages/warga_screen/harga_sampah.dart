import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HargaSampah extends StatefulWidget {
  const HargaSampah({super.key});

  @override
  State<HargaSampah> createState() => _HargaSampahState();
}

class _HargaSampahState extends State<HargaSampah> {
  final String baseUrl = 'https://jera.kerissumenep.com/api';

  Future<List<dynamic>> fetchHargaSampah() async {
    final response = await http.get(Uri.parse('$baseUrl/harga-barang'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal koneksi ke API');
    }
  }

  String formatHarga(String harga) {
    double? hargaDouble = double.tryParse(harga);
    if (hargaDouble == null) return '0';
    return hargaDouble % 1 == 0
        ? hargaDouble.toInt().toString()
        : hargaDouble.toString();
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Waktu tidak tersedia';
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return 'Format waktu tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Harga Sampah',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchHargaSampah(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final hargaSampahList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: hargaSampahList.length,
              itemBuilder: (context, index) {
                final item = hargaSampahList[index] as Map<String, dynamic>;
                final namaBarang = item['Nama_Barang'] ?? 'Tidak tersedia';
                final hargaBeli = item['Harga_Beli'] ?? '0';
                final timestamp = item['updated_at'];
                String gambarLink = item['gambar'] ?? '';

                if (gambarLink.isNotEmpty) {
                  gambarLink = '$baseUrl$gambarLink'.replaceAll(r'\', '');
                } else {
                  gambarLink = '';
                }
                print('gambar: $gambarLink');

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              gambarLink,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          namaBarang,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Rp${formatHarga(hargaBeli)}',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          formatTimestamp(timestamp),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
