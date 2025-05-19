import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Auth/face-verification.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:security_rental/Screen/Widget/Common/custom_buttom.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import 'package:security_rental/Service/auth_service.dart';
import '../../config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle, size: 64.w, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'Anda belum login',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Silakan login untuk melihat profil Anda',
              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              width: 200.w,
            ),
          ],
        ),
      );
    }

    if (authService.isLoading) return Center(child: LoadingWidget());

    final user = authService.currentUser!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.faceImagePath != null
                        ? NetworkImage(user.faceImagePath!)
                        : null,
                    child: user.faceImagePath == null
                        ? Icon(Icons.person,
                            size: 50.r, color: Colors.grey[400])
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    user.username,
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.lvlUsers,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  // user.faceId != null
                  //     ? Container(
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 12.w, vertical: 4.h),
                  //         decoration: BoxDecoration(
                  //           color: Colors.green[50],
                  //           borderRadius: BorderRadius.circular(16.r),
                  //           border: Border.all(color: Colors.green),
                  //         ),
                  //         child: Row(
                  //           mainAxisSize: MainAxisSize.min,
                  //           children: [
                  //             Icon(Icons.verified_user,
                  //                 size: 16.w, color: Colors.green),
                  //             SizedBox(width: 4.w),
                  //             Text(
                  //               'Terverifikasi',
                  //               style: TextStyle(
                  //                   color: Colors.green,
                  //                   fontWeight: FontWeight.bold,
                  //                   fontSize: 13.sp),
                  //             ),
                  //           ],
                  //         ),
                  //       )
                  //     : InkWell(
                  //         onTap: () {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (_) => FaceVerificationScreen()),
                  //           );
                  //         },
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(
                  //               horizontal: 12.w, vertical: 4.h),
                  //           decoration: BoxDecoration(
                  //             color: Colors.orange[50],
                  //             borderRadius: BorderRadius.circular(16.r),
                  //             border: Border.all(color: Colors.orange),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               Icon(Icons.warning,
                  //                   size: 16.w, color: Colors.orange),
                  //               SizedBox(width: 4.w),
                  //               Text(
                  //                 'Belum Diverifikasi',
                  //                 style: TextStyle(
                  //                     color: Colors.orange,
                  //                     fontWeight: FontWeight.bold,
                  //                     fontSize: 13.sp),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                ],
              ),
            ),
            _buildSection(context, title: 'Lainnya', items: [
              ProfileMenuItem(
                  icon: Icons.help_outline, title: 'Bantuan', onTap: () {}),
              ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AboutDialog(
                      applicationName: AppConfig.appName,
                      applicationVersion: AppConfig.appVersion,
                      applicationIcon: Icon(Icons.directions_car,
                          size: 40.w, color: Theme.of(context).primaryColor),
                      children: [
                        Text(
                          'Aplikasi peminjaman mobil dengan verifikasi wajah.',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Logout',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Batal')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Ya')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await authService.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              },
              color: Colors.red,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                leading: Icon(
                  item.icon,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  item.title,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                trailing: item.onTap != null
                    ? const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      )
                    : null,
                onTap: item.onTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
