import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:security_rental/Model/rental_model.dart';
import 'package:security_rental/Screen/Home/car_verification.dart';
import 'package:security_rental/Screen/Widget/Common/custom_buttom.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Service/rental_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RentalCard extends StatefulWidget {
  final Rental rental;

  RentalCard({super.key, required this.rental});

  @override
  State<RentalCard> createState() => _RentalCardState();
}

class _RentalCardState extends State<RentalCard> {
  bool _isLoading = false;

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

  // Method untuk verifikasi mobil keluar (approved -> onGoing)
  Future<void> _handleCarOutVerification() async {
    // Navigate ke CarVerificationScreen untuk mobil keluar
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarVerificationScreen(
          rental: widget.rental,
          isCarOut: true, // true untuk verifikasi keluar
        ),
      ),
    );

    // Jika verifikasi berhasil, refresh data
    if (result == true) {
      final rentalService = Provider.of<RentalService>(context, listen: false);
      await rentalService.refreshRentals('');
    }
  }

  // Method untuk verifikasi mobil masuk (onGoing -> completed)
  Future<void> _handleCarInVerification() async {
    // Navigate ke CarVerificationScreen untuk mobil masuk
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarVerificationScreen(
          rental: widget.rental,
          isCarOut: false, // false untuk verifikasi masuk
        ),
      ),
    );

    // Jika verifikasi berhasil, refresh data
    if (result == true) {
      final rentalService = Provider.of<RentalService>(context, listen: false);
      await rentalService.refreshRentals('');
    }
  }

  // Helper method untuk menampilkan dialog hasil
  Future<void> _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isSuccess ? Colors.green : Colors.red,
                      ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'OK',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
                  'ID: ${widget.rental.id}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(widget.rental.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _getStatusColor(widget.rental.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(widget.rental.status),
                    style: TextStyle(
                      color: _getStatusColor(widget.rental.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Car Info
          if (widget.rental.car != null)
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  // Container(
                  //   width: 70,
                  //   height: 50,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(4),
                  //     image: DecorationImage(
                  //       image: NetworkImage(widget.rental.car!.imgUrl ??
                  //               'https://via.placeholder.com/150' // Placeholder image
                  //           ),
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.rental.car!.merk} ${widget.rental.car!.model}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.rental.car!.plat,
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
                _buildDetailRow('Nama', widget.rental.namaPenyewa, context),
                _buildDetailRow(
                    'Tanggal',
                    '${dateFormatter.format(widget.rental.tanggalMulaiSewa)} - ${dateFormatter.format(widget.rental.tanggalAkhirSewa)}',
                    context),
                const SizedBox(height: 4),
                _buildDetailRow(
                    'Durasi',
                    '${widget.rental.tanggalAkhirSewa.difference(widget.rental.tanggalMulaiSewa).inDays + 1} hari',
                    context),
                const SizedBox(height: 4),

                // Menampilkan tambahan sewa jika ada
                if (widget.rental.tambahanSewa != null &&
                    widget.rental.tambahanSewa!.isNotEmpty)
                  _buildDetailRow(
                      'Tambahan', widget.rental.tambahanSewa!, context),

                // Menampilkan kerusakan jika ada
                if (widget.rental.kerusakan != null &&
                    widget.rental.kerusakan!.isNotEmpty)
                  _buildDetailRow(
                      'Kerusakan', widget.rental.kerusakan!, context,
                      valueColor: Colors.red),

                // Menampilkan status verifikasi wajah jika sudah terverifikasi
                if (widget.rental.verifikasiWajahMasukStatus == 1)
                  _buildDetailRow(
                      'Verifikasi Masuk',
                      'Terverifikasi ${widget.rental.verifikasiWajahMasukTimestamp != null ? DateFormat('dd MMM yyyy HH:mm').format(widget.rental.verifikasiWajahMasukTimestamp!) : ""}',
                      context,
                      valueColor: Colors.green),

                if (widget.rental.verifikasiWajahKeluarStatus == 1)
                  _buildDetailRow(
                      'Verifikasi Keluar',
                      'Terverifikasi ${widget.rental.verifikasiWajahKeluarTimestamp != null ? DateFormat('dd MMM yyyy HH:mm').format(widget.rental.verifikasiWajahKeluarTimestamp!) : ""}',
                      context,
                      valueColor: Colors.green),
              ],
            ),
          ),

          // Actions untuk status approved (mobil keluar) - Navigate to verification
          if (widget.rental.status == RentalStatus.approved)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCarOutVerification,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.logout, size: 18),
                  label:
                      Text(_isLoading ? 'Processing...' : 'Verifikasi Keluar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          // Actions untuk status onGoing (mobil masuk) - Navigate to verification
          if (widget.rental.status == RentalStatus.onGoing)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCarInVerification,
                  icon: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.login, size: 18),
                  label:
                      Text(_isLoading ? 'Processing...' : 'Verifikasi Masuk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
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
