import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:security_rental/Screen/Auth/face-verification.dart';
import 'package:security_rental/Screen/Auth/login-screen.dart';
import 'package:security_rental/Screen/Widget/Common/custom_buttom.dart';
import 'package:security_rental/Screen/Widget/Common/loading_widget.dart';
import '../../service/auth_service.dart';
import '../../config/app_config.dart';

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
            const Icon(
              Icons.account_circle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Anda belum login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan login untuk melihat profil Anda',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              width: 200,
            ),
          ],
        ),
      );
    }

    if (authService.isLoading) {
      return Center(child: LoadingWidget());
    }

    final user = authService.currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: user.faceImagePath != null
                      ? NetworkImage(user.faceImagePath!)
                      : null,
                  child: user.faceImagePath == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.lvlUsers,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                user.faceId != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 16,
                              color: Colors.green,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Terverifikasi',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FaceVerificationScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                size: 16,
                                color: Colors.orange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Belum Diverifikasi',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Profile Info Sections
          _buildSection(
            context,
            title: 'Informasi Pribadi',
            items: [
              // ProfileMenuItem(
              //   icon: Icons.phone,
              //   title: 'Nomor Telepon',
              //   subtitle: user.phone,
              // ),
              // if (user.idCardNumber != null)
              //   ProfileMenuItem(
              //     icon: Icons.credit_card,
              //     title: 'Nomor KTP',
              //     subtitle: user.idCardNumber!,
              //   ),
              // if (user.drivingLicense != null)
              //   ProfileMenuItem(
              //     icon: Icons.drive_eta,
              //     title: 'Nomor SIM',
              //     subtitle: user.drivingLicense!,
              //   ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSection(
            context,
            title: 'Pengaturan',
            items: [
              ProfileMenuItem(
                icon: Icons.edit,
                title: 'Edit Profil',
                onTap: () {
                  // Navigate to edit profile
                },
              ),
              ProfileMenuItem(
                icon: Icons.lock,
                title: 'Ubah Password',
                onTap: () {
                  // Navigate to change password
                },
              ),
              ProfileMenuItem(
                icon: Icons.notifications,
                title: 'Notifikasi',
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSection(
            context,
            title: 'Lainnya',
            items: [
              ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {
                  // Navigate to help
                },
              ),
              ProfileMenuItem(
                icon: Icons.info_outline,
                title: 'Tentang Aplikasi',
                onTap: () {
                  // Show about dialog
                  showDialog(
                    context: context,
                    builder: (context) => AboutDialog(
                      applicationName: AppConfig.appName,
                      applicationVersion: AppConfig.appVersion,
                      applicationIcon: Icon(
                        Icons.directions_car,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                      children: const [
                        Text(
                          'Aplikasi peminjaman mobil dengan verifikasi wajah.',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Logout Button
          CustomButton(
            text: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
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

          const SizedBox(height: 32),
        ],
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
                title: Text(item.title),
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
