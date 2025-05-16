import 'package:security_rental/Model/car_model.dart';

enum RentalStatus {
  pending,
  approved,
  onGoing,
  completed,
  cancelled,
  rejected,
}

class Rental {
  final int id; // dari 'id_transaksi'
  final String mobilId; // dari 'mobil_id' (string sesuai JSON)
  final String namaPenyewa; // dari 'nama_penyewa'
  final DateTime tanggalMulaiSewa;
  final DateTime tanggalAkhirSewa;
  final DateTime? tanggalKembali; // dari 'tanggal_kembali', bisa null
  final String? tambahanSewa; // dari 'tambahan_sewa', bisa null
  final String? kerusakan; // dari 'kerusakan', bisa null
  final double? totalBiaya; // nullable sesuai json bisa null
  final String? denda; // dari 'denda', bisa null
  final int verifikasiWajahMasukStatus; // dari 'verifikasi_wajah_masuk_status'
  final DateTime?
      verifikasiWajahMasukTimestamp; // dari 'verifikasi_wajah_masuk_timestamp', bisa null
  final String?
      verifikasiWajahMasukFoto; // dari 'verifikasi_wajah_masuk_foto', bisa null
  final String?
      verifikasiWajahMasukConfidence; // dari 'verifikasi_wajah_masuk_confidence', bisa null
  final int
      verifikasiWajahKeluarStatus; // dari 'verifikasi_wajah_keluar_status'
  final DateTime?
      verifikasiWajahKeluarTimestamp; // dari 'verifikasi_wajah_keluar_timestamp', bisa null
  final String?
      verifikasiWajahKeluarFoto; // dari 'verifikasi_wajah_keluar_foto', bisa null
  final String?
      verifikasiWajahKeluarConfidence; // dari 'verifikasi_wajah_keluar_confidence', bisa null
  final String?
      verifikasiWajahKeterangan; // dari 'verifikasi_wajah_keterangan', bisa null
  final RentalStatus status;
  final DateTime createdAt; // dari 'created_at'
  final Car? car; // dari 'mobil'

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
    required this.status,
    required this.createdAt,
    this.car,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    // Determine status based on the value in JSON
    RentalStatus determineStatus(String? statusStr) {
      if (statusStr == null || statusStr.isEmpty) {
        return RentalStatus.pending;
      }

      switch (statusStr.toLowerCase()) {
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
      verifikasiWajahMasukStatus:
          int.tryParse(json['verifikasi_wajah_masuk_status'].toString()) ?? 0,
      verifikasiWajahMasukTimestamp:
          json['verifikasi_wajah_masuk_timestamp'] != null
              ? DateTime.parse(json['verifikasi_wajah_masuk_timestamp'])
              : null,
      verifikasiWajahMasukFoto: json['verifikasi_wajah_masuk_foto'],
      verifikasiWajahMasukConfidence: json['verifikasi_wajah_masuk_confidence'],
      verifikasiWajahKeluarStatus:
          int.tryParse(json['verifikasi_wajah_keluar_status'].toString()) ?? 0,
      verifikasiWajahKeluarTimestamp:
          json['verifikasi_wajah_keluar_timestamp'] != null
              ? DateTime.parse(json['verifikasi_wajah_keluar_timestamp'])
              : null,
      verifikasiWajahKeluarFoto: json['verifikasi_wajah_keluar_foto'],
      verifikasiWajahKeluarConfidence:
          json['verifikasi_wajah_keluar_confidence'],
      verifikasiWajahKeterangan: json['verifikasi_wajah_keterangan'],
      status: determineStatus(json['status']),
      createdAt: DateTime.parse(json['created_at']),
      car: json['mobil'] != null ? Car.fromJson(json['mobil']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String statusToString(RentalStatus status) {
      switch (status) {
        case RentalStatus.completed:
          return 'completed';
        case RentalStatus.cancelled:
          return 'cancelled';
        case RentalStatus.pending:
          return 'pending';
        case RentalStatus.approved:
          return 'approved';
        case RentalStatus.onGoing:
          return 'ongoing';
        case RentalStatus.rejected:
          return 'rejected';
        default:
          return '';
      }
    }

    return {
      'id_transaksi': id,
      'mobil_id': mobilId,
      'nama_penyewa': namaPenyewa,
      'tanggal_mulai_sewa': tanggalMulaiSewa.toIso8601String(),
      'tanggal_akhir_sewa': tanggalAkhirSewa.toIso8601String(),
      'tanggal_kembali': tanggalKembali?.toIso8601String(),
      'tambahan_sewa': tambahanSewa,
      'kerusakan': kerusakan,
      'total_biaya': totalBiaya?.toString(),
      'denda': denda,
      'verifikasi_wajah_masuk_status': verifikasiWajahMasukStatus,
      'verifikasi_wajah_masuk_timestamp':
          verifikasiWajahMasukTimestamp?.toIso8601String(),
      'verifikasi_wajah_masuk_foto': verifikasiWajahMasukFoto,
      'verifikasi_wajah_masuk_confidence': verifikasiWajahMasukConfidence,
      'verifikasi_wajah_keluar_status': verifikasiWajahKeluarStatus,
      'verifikasi_wajah_keluar_timestamp':
          verifikasiWajahKeluarTimestamp?.toIso8601String(),
      'verifikasi_wajah_keluar_foto': verifikasiWajahKeluarFoto,
      'verifikasi_wajah_keluar_confidence': verifikasiWajahKeluarConfidence,
      'verifikasi_wajah_keterangan': verifikasiWajahKeterangan,
      'status': statusToString(status),
      'created_at': createdAt.toIso8601String(),
      'mobil': car?.toJson(),
    };
  }
}

class Car {
  final int mobilId;
  final String plat;
  final String merk;
  final String model;
  final String type;
  final String tahun;
  final String warna;
  final double hargaSewa;
  final String? imgUrl;
  final String status;

  Car({
    required this.mobilId,
    required this.plat,
    required this.merk,
    required this.model,
    required this.type,
    required this.tahun,
    required this.warna,
    required this.hargaSewa,
    this.imgUrl,
    required this.status,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      mobilId: json['mobil_id'],
      plat: json['plat'],
      merk: json['merk'],
      model: json['model'],
      type: json['type'] ?? '',
      tahun: json['tahun'],
      warna: json['warna'],
      hargaSewa: double.tryParse(json['harga_sewa'].toString()) ?? 0.0,
      imgUrl: json['img_url'],
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mobil_id': mobilId,
      'plat': plat,
      'merk': merk,
      'model': model,
      'type': type,
      'tahun': tahun,
      'warna': warna,
      'harga_sewa': hargaSewa.toString(),
      'img_url': imgUrl,
      'status': status,
    };
  }
}
