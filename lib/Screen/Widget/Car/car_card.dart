import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:security_rental/Model/car_model.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarCard extends StatelessWidget {
  final Car car;

  CarCard({super.key, required this.car});

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                car.img_url!.isNotEmpty
                    ? car.img_url!
                    : 'https://via.placeholder.com/400x225?text=No+Image',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Car Info
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${car.merk} ${car.model}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        car.type,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 20.sp),
                    SizedBox(width: 4.w),
                    Text(
                      ": dimas M Kahfi",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 16.sp,
                              ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Mulai sewa:",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 16.sp,
                              ),
                    ),
                    SizedBox(width: 4.w),
                    Text("18:00:00 24 Jan 2024",
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Akhir sewa:",
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 16.sp,
                              ),
                    ),
                    SizedBox(width: 4.w),
                    Text("18:00:00 24 Jan 2024",
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: Colors.grey[600],
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
