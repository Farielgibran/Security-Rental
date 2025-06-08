enum RentalStatus {
  pending,
  approved,
  onGoing,
  completed,
  cancelled,
  rejected,
}

class Rental {
  final int id;
  final String mobilId;
  final String namaPenyewa;
  final DateTime tanggalMulaiSewa;
  final DateTime tanggalAkhirSewa;
  final DateTime? tanggalKembali;
  final String? tambahanSewa;
  final String? kerusakan;
  final double? totalBiaya;
  final String? denda;

  final int verifikasiWajahMasukStatus;
  final DateTime? verifikasiWajahMasukTimestamp;
  final String? verifikasiWajahMasukFoto;
  final String? verifikasiWajahMasukConfidence;

  final int verifikasiWajahKeluarStatus;
  final DateTime? verifikasiWajahKeluarTimestamp;
  final String? verifikasiWajahKeluarFoto;
  final String? verifikasiWajahKeluarConfidence;
  final String? verifikasiWajahKeterangan;

  final String? approvalBy;
  final DateTime? approvalAt;

  final String? keteranganPengajuan;
  final String? alasanPenolakan;

  final bool statusMobilKeluar;
  final double? kilometerKeluar;
  final String? bensinKeluar;
  final String? kondisiFisikKeluar;
  final DateTime? tanggalMobilKeluar;

  final bool statusMobilMasuk;
  final double? kilometerMasuk;
  final String? bensinMasuk;
  final String? kondisiFisikMasuk;
  final DateTime? tanggalMobilMasuk;

  final RentalStatus status;
  final DateTime createdAt;

  final Car? car;

  Rental({
    required this.id,
    required this.mobilId,
    required this.namaPenyewa,
    required this.tanggalMulaiSewa,
    required this.tanggalAkhirSewa,
    this.tanggalKembali,
    this.tambahanSewa,
    this.kerusakan,
    this.totalBiaya,
    this.denda,
    required this.verifikasiWajahMasukStatus,
    this.verifikasiWajahMasukTimestamp,
    this.verifikasiWajahMasukFoto,
    this.verifikasiWajahMasukConfidence,
    required this.verifikasiWajahKeluarStatus,
    this.verifikasiWajahKeluarTimestamp,
    this.verifikasiWajahKeluarFoto,
    this.verifikasiWajahKeluarConfidence,
    this.verifikasiWajahKeterangan,
    this.approvalBy,
    this.approvalAt,
    this.keteranganPengajuan,
    this.alasanPenolakan,
    required this.statusMobilKeluar,
    this.kilometerKeluar,
    this.bensinKeluar,
    this.kondisiFisikKeluar,
    this.tanggalMobilKeluar,
    required this.statusMobilMasuk,
    this.kilometerMasuk,
    this.bensinMasuk,
    this.kondisiFisikMasuk,
    this.tanggalMobilMasuk,
    required this.status,
    required this.createdAt,
    this.car,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    RentalStatus determineStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'completed':
          return RentalStatus.completed;
        case 'cancelled':
          return RentalStatus.cancelled;
        case 'pending':
          return RentalStatus.pending;
        case 'approved':
          return RentalStatus.approved;
        case 'ongoing':
          return RentalStatus.onGoing;
        case 'rejected':
          return RentalStatus.rejected;
        default:
          return RentalStatus.pending;
      }
    }

    return Rental(
      id: json['id_transaksi'],
      mobilId: json['mobil_id'].toString(),
      namaPenyewa: json['nama_penyewa'] ?? '',
      tanggalMulaiSewa: DateTime.parse(json['tanggal_mulai_sewa']),
      tanggalAkhirSewa: DateTime.parse(json['tanggal_akhir_sewa']),
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.parse(json['tanggal_kembali'])
          : null,
      tambahanSewa: json['tambahan_sewa'],
      kerusakan: json['kerusakan'],
      totalBiaya: json['total_biaya'] != null
          ? double.tryParse(json['total_biaya'].toString())
          : null,
      denda: json['denda'],
      verifikasiWajahMasukStatus: int.tryParse(
              json['verifikasi_wajah_masuk_status']?.toString() ?? '0') ??
          0,
      verifikasiWajahMasukTimestamp:
          json['verifikasi_wajah_masuk_timestamp'] != null
              ? DateTime.parse(json['verifikasi_wajah_masuk_timestamp'])
              : null,
      verifikasiWajahMasukFoto: json['verifikasi_wajah_masuk_foto'],
      verifikasiWajahMasukConfidence: json['verifikasi_wajah_masuk_confidence'],
      verifikasiWajahKeluarStatus: int.tryParse(
              json['verifikasi_wajah_keluar_status']?.toString() ?? '0') ??
          0,
      verifikasiWajahKeluarTimestamp:
          json['verifikasi_wajah_keluar_timestamp'] != null
              ? DateTime.parse(json['verifikasi_wajah_keluar_timestamp'])
              : null,
      verifikasiWajahKeluarFoto: json['verifikasi_wajah_keluar_foto'],
      verifikasiWajahKeluarConfidence:
          json['verifikasi_wajah_keluar_confidence'],
      verifikasiWajahKeterangan: json['verifikasi_wajah_keterangan'],
      approvalBy: json['approval_by']?.toString(),
      approvalAt: json['approval_at'] != null
          ? DateTime.parse(json['approval_at'])
          : null,
      keteranganPengajuan: json['keterangan_pengajuan'],
      alasanPenolakan: json['alasan_penolakan'],
      statusMobilKeluar: json['status_mobil_keluar'] ?? false,
      kilometerKeluar: json['kilometer_keluar'] != null
          ? double.tryParse(json['kilometer_keluar'].toString())
          : null,
      bensinKeluar: json['bensin_keluar'],
      kondisiFisikKeluar: json['kondisi_fisik_keluar'],
      tanggalMobilKeluar: json['tanggal_mobil_keluar'] != null
          ? DateTime.parse(json['tanggal_mobil_keluar'])
          : null,
      statusMobilMasuk: json['status_mobil_masuk'] ?? false,
      kilometerMasuk: json['kilometer_masuk'] != null
          ? double.tryParse(json['kilometer_masuk'].toString())
          : null,
      bensinMasuk: json['bensin_masuk'],
      kondisiFisikMasuk: json['kondisi_fisik_masuk'],
      tanggalMobilMasuk: json['tanggal_mobil_masuk'] != null
          ? DateTime.parse(json['tanggal_mobil_masuk'])
          : null,
      status: determineStatus(json['status_peminjaman']),
      createdAt: DateTime.parse(json['created_at']),
      car: json['mobil'] != null ? Car.fromJson(json['mobil']) : null,
    );
  }
}

class Car {
  final int mobilId;
  final String merk;
  final String model;
  final String plat;
  final String warna;
  final String tahun;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Car({
    required this.mobilId,
    required this.merk,
    required this.model,
    required this.plat,
    required this.warna,
    required this.tahun,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      mobilId: json['mobil_id'],
      merk: json['merk'],
      model: json['model'],
      plat: json['plat'],
      warna: json['warna'],
      tahun: json['tahun'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'mobil_id': mobilId,
        'merk': merk,
        'model': model,
        'plat': plat,
        'warna': warna,
        'tahun': tahun,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
