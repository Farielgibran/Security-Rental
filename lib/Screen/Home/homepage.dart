import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Contoh data
  final List<Map<String, String>> _dataList = [
    {
      'status': 'Hadir',
      'waktuMasuk': '08:00',
      'waktuKeluar': '17:00',
      'username': 'Budi',
      'mobil': 'Avanza',
    },
    {
      'status': 'Terlambat',
      'waktuMasuk': '09:15',
      'waktuKeluar': '17:00',
      'username': 'Siti',
      'mobil': 'Brio',
    },
    {
      'status': 'Izin',
      'waktuMasuk': '-',
      'waktuKeluar': '-',
      'username': 'Andi',
      'mobil': '-',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kehadiran'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dataList.length,
        itemBuilder: (context, index) {
          final item = _dataList[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed("");
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 24.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12.r)),
                      child: Text(
                        "Status",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nama: ",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.black),
                      ),
                      Expanded(
                        child: Text(
                          "Dimas",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Batasi jika ingin satu baris saja
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.car_rental),
                      Text(
                        "mobil: ",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.black),
                      ),
                      Expanded(
                        child: Text(
                          "Agya Turbo",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1, // Batasi jika ingin satu baris saja
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Waktu keluar ",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: Colors.black),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 6.h),
                              width: 12.w,
                              height: 2.h,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 6.h,
                            ),
                            Text(
                              "24 Januari 2025 ",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              "12:00:00 ",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 12.h,
                        ),
                        Column(
                          children: [
                            Text(
                              "Waktu  Masuk",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: Colors.black),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 6.h),
                              width: 12.w,
                              height: 2.h,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: 6.h,
                            ),
                            Text(
                              "24 Januari 2025 ",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              "12:00:00 ",
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.h,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Detail >> ",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
