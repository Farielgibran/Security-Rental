class Car {
  final int mobilId;
  final String plat;
  final String merk;
  final String model;
  final String type;
  final String tahun;
  final String warna;
  final String hargaSewa;
  final String status;
  final String? img_url;

  Car({
    required this.mobilId,
    required this.plat,
    required this.merk,
    required this.model,
    required this.type,
    required this.tahun,
    required this.warna,
    required this.hargaSewa,
    required this.status,
    this.img_url,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      mobilId: json['mobil_id'],
      plat: json['plat'],
      merk: json['merk'],
      model: json['model'],
      type: json['type'],
      tahun: json['tahun'],
      warna: json['warna'],
      hargaSewa: json['harga_sewa'],
      status: json['status'],
      img_url: json['img_url'],
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
      'harga_sewa': hargaSewa,
      'status': status,
      'img_url': img_url,
    };
  }
}
