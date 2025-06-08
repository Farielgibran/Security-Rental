import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Service/rental_service.dart';

class PemeriksaanKendaraanScreen extends StatefulWidget {
  final String transaksiId;
  final String tipePemeriksaan; // 'keluar' atau 'masuk'
  final String namaPenyewa;
  final String merkMobil;
  final String platMobil;

  const PemeriksaanKendaraanScreen({
    Key? key,
    required this.transaksiId,
    required this.tipePemeriksaan,
    required this.namaPenyewa,
    required this.merkMobil,
    required this.platMobil,
  }) : super(key: key);

  @override
  State<PemeriksaanKendaraanScreen> createState() =>
      _PemeriksaanKendaraanScreenState();
}

class _PemeriksaanKendaraanScreenState extends State<PemeriksaanKendaraanScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form variables
  bool _oli = false;
  bool _tekananBan = false;
  bool _toolSet = false;
  bool _mesin = false;
  String _catatan = '';
  bool _isLoading = false;

  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Color(0xff121212),
                    Color(0xff1E1E1E),
                    Color(0xff2A2A2A),
                  ]
                : [
                    Colors.white,
                    Color(0xffF8F9FA),
                    Color(0xffE3F2FD),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            _buildInfoCard(),
                            SizedBox(height: 20.h),
                            _buildChecklistCard(),
                            SizedBox(height: 20.h),
                            _buildCatatanCard(),
                            SizedBox(height: 30.h),
                            _buildActionButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemeriksaan ${widget.tipePemeriksaan == "keluar" ? "Keluar" : "Masuk"}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Verifikasi kondisi kendaraan',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: widget.tipePemeriksaan == "keluar"
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.tipePemeriksaan == "keluar"
                  ? Icons.exit_to_app
                  : Icons.assignment_return,
              color: widget.tipePemeriksaan == "keluar"
                  ? Colors.orange
                  : Colors.green,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xff1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Informasi Transaksi',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _buildInfoRow('ID Transaksi', widget.transaksiId),
          _buildInfoRow('Nama Penyewa', widget.namaPenyewa),
          _buildInfoRow('Merek Mobil', widget.merkMobil),
          _buildInfoRow('Plat Nomor', widget.platMobil),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondary
                        .withOpacity(0.7),
                  ),
            ),
          ),
          Text(
            ': ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSecondary
                      .withOpacity(0.7),
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xff1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.checklist,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Checklist Pemeriksaan',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildChecklistItem(
            'Oli Mesin',
            _oli,
            (value) => setState(() => _oli = value),
            Icons.oil_barrel,
            Colors.amber,
          ),
          _buildChecklistItem(
            'Tekanan Ban',
            _tekananBan,
            (value) => setState(() => _tekananBan = value),
            Icons.tire_repair,
            Colors.blue,
          ),
          _buildChecklistItem(
            'Tool Set',
            _toolSet,
            (value) => setState(() => _toolSet = value),
            Icons.build,
            Colors.purple,
          ),
          _buildChecklistItem(
            'Kondisi Mesin',
            _mesin,
            (value) => setState(() => _mesin = value),
            Icons.settings,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    String title,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: value
            ? color.withOpacity(0.1)
            : Theme.of(context).colorScheme.onSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: value ? color.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:
                  value ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: value ? color : Colors.grey,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: value
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context)
                            .colorScheme
                            .onSecondary
                            .withOpacity(0.7),
                  ),
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Color(0xff1E1E1E)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.note_alt,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Catatan Pemeriksaan',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.onSecondary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _catatanController,
              maxLines: 4,
              onChanged: (value) => setState(() => _catatan = value),
              style: Theme.of(context).textTheme.labelMedium,
              decoration: InputDecoration(
                hintText:
                    'Tulis catatan tambahan mengenai kondisi kendaraan...',
                hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.5),
                    ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    bool allChecked = _oli && _tekananBan && _toolSet && _mesin;

    return Container(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPemeriksaan,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              allChecked ? Colors.green : Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor:
              (allChecked ? Colors.green : Theme.of(context).primaryColor)
                  .withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Memproses...',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    allChecked ? Icons.check_circle : Icons.warning,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    allChecked
                        ? 'Lulus Pemeriksaan'
                        : 'Tidak Lulus Pemeriksaan',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _submitPemeriksaan() async {
    setState(() => _isLoading = true);

    try {
      final rentalService = Provider.of<RentalService>(context, listen: false);
      Map<String, dynamic> result;

      // Panggil API sesuai dengan tipe pemeriksaan
      if (widget.tipePemeriksaan == 'keluar') {
        // Verifikasi mobil keluar (approved -> onGoing)
        result = await rentalService.verifikasiMobilKeluar(
          transaksiId: widget.transaksiId,
          oli: _oli,
          tekananBan: _tekananBan,
          toolSet: _toolSet,
          mesin: _mesin,
          catatan: _catatan.isNotEmpty ? _catatan : null,
        );
      } else {
        // Verifikasi mobil masuk (onGoing -> completed)
        result = await rentalService.verifikasiMobilMasuk(
          transaksiId: widget.transaksiId,
          oli: _oli,
          tekananBan: _tekananBan,
          toolSet: _toolSet,
          mesin: _mesin,
          catatan: _catatan.isNotEmpty ? _catatan : null,
        );
      }

      // Handle response
      if (result['success'] == true) {
        // Show success dialog
        await _showResultDialog(
          title: 'Pemeriksaan Berhasil',
          message:
              result['message'] ?? 'Verifikasi kendaraan berhasil dilakukan',
          isSuccess: true,
        );

        // Refresh data dan kembali ke halaman sebelumnya
        await rentalService
            .refreshRentals(''); // Pass appropriate user ID if needed

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Show error dialog
        await _showResultDialog(
          title: 'Pemeriksaan Gagal',
          message: result['message'] ??
              'Terjadi kesalahan saat verifikasi kendaraan',
          isSuccess: false,
        );
      }
    } catch (e) {
      // Show error dialog for exceptions
      await _showResultDialog(
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
}
