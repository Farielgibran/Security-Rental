import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:security_rental/Model/rental_model.dart';
import 'package:security_rental/Screen/Widget/Common/custom_buttom.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Service/rental_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RentalCard extends StatelessWidget {
  final Rental rental;

  RentalCard({super.key, required this.rental});

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final dateFormatter = DateFormat('dd MMM yyyy');

  // Mendapatkan warna status
  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return Colors.orange;
      case RentalStatus.approved:
        return Colors.blue;
      case RentalStatus.onGoing:
        return Colors.green;
      case RentalStatus.completed:
        return Colors.teal;
      case RentalStatus.cancelled:
        return Colors.red;
      case RentalStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Mendapatkan text status
  String _getStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return 'Menunggu Persetujuan';
      case RentalStatus.approved:
        return 'Disetujui';
      case RentalStatus.onGoing:
        return 'Sedang Berjalan';
      case RentalStatus.completed:
        return 'Selesai';
      case RentalStatus.cancelled:
        return 'Dibatalkan';
      case RentalStatus.rejected:
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }

  // Batalkan rental
  Future<void> verifikasikeluar(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('confirmasi mobil keluar'),
          content: const Text('Apakah Anda yakin ingin keluar verifikasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final rentalService = Provider.of<RentalService>(context, listen: false);
      final success = await rentalService.verifikasiMobilKeluar(
        rental: rental.id.toString(),
        token: 'your-token',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('mobil terverifikasi keluar'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal verifikasi keluar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Batalkan rental
  Future<void> verifikasimasuk(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('confirmasi mobil masuk'),
          content:
              const Text('Apakah Anda yakin ingin masuk mobil verifikasi ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final rentalService = Provider.of<RentalService>(context, listen: false);
      final success = await rentalService.verifikasiMobilmasuk(
        rental: rental.id.toString(),
        token: 'your-token',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('mobil terverifikasi masuk kembali'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal verifikasi mobil masuk kembali'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${rental.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(rental.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(rental.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(rental.status),
                    style: TextStyle(
                      color: _getStatusColor(rental.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Text(rental.namaPenyewa,
                style: Theme.of(context).textTheme.headlineMedium),
          ),
          // Car Info
          if (rental.car != null)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: NetworkImage(rental.car!.imgUrl ??
                                'https://via.placeholder.com/150' // Placeholder image
                            ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${rental.car!.merk} ${rental.car!.model}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rental.car!.plat,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Rental Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildDetailRow(
                    'Tanggal',
                    '${dateFormatter.format(rental.tanggalMulaiSewa)} - ${dateFormatter.format(rental.tanggalAkhirSewa)}',
                    context),
                const SizedBox(height: 4),
                _buildDetailRow(
                    'Durasi',
                    '${rental.tanggalAkhirSewa.difference(rental.tanggalMulaiSewa).inDays + 1} hari',
                    context),
                const SizedBox(height: 4),

                // Menampilkan tambahan sewa jika ada
                if (rental.tambahanSewa != null &&
                    rental.tambahanSewa!.isNotEmpty)
                  _buildDetailRow('Tambahan', rental.tambahanSewa!, context),

                // Menampilkan kerusakan jika ada
                if (rental.kerusakan != null && rental.kerusakan!.isNotEmpty)
                  _buildDetailRow(
                      'Kerusakan',
                      rental.kerusakan!,
                      valueColor: Colors.red,
                      context),

                // Menampilkan status verifikasi wajah jika sudah terverifikasi
                if (rental.verifikasiWajahMasukStatus == 1)
                  _buildDetailRow(
                      'Verifikasi Masuk',
                      'Terverifikasi ${rental.verifikasiWajahMasukTimestamp != null ? DateFormat('dd MMM yyyy HH:mm').format(rental.verifikasiWajahMasukTimestamp!) : ""}',
                      valueColor: Colors.green,
                      context),

                if (rental.verifikasiWajahKeluarStatus == 1)
                  _buildDetailRow(
                      'Verifikasi Keluar',
                      'Terverifikasi ${rental.verifikasiWajahKeluarTimestamp != null ? DateFormat('dd MMM yyyy HH:mm').format(rental.verifikasiWajahKeluarTimestamp!) : ""}',
                      valueColor: Colors.green,
                      context),
              ],
            ),
          ),

          // Actions
          if (rental.status == RentalStatus.approved)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Verifikasi Mobil Keluar',
                      onPressed: () => verifikasikeluar(context),
                      color: Colors.red,
                      height: 36,
                      icon: Icons.door_back_door,
                    ),
                  ),
                ],
              ),
            ),

          // Actions
          if (rental.status == RentalStatus.onGoing)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Verifikasi Mobil kembali masuk',
                      onPressed: () => verifikasimasuk(context),
                      color: Colors.green,
                      height: 36,
                      icon: Icons.cancel,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: valueBold ? FontWeight.bold : null,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
