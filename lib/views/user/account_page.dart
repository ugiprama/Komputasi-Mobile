import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:applaporwarga/widgets/bottom_nav.dart';
import 'package:applaporwarga/views/laporan/laporan_list_page.dart';
import 'package:applaporwarga/views/user/widgets/edit_profil_page.dart'; // Import untuk halaman edit profil
import 'package:applaporwarga/views/user/widgets/help_page.dart'; // Import untuk halaman bantuan
import 'package:applaporwarga/views/user/widgets/setting_page.dart'; // Import untuk halaman pengaturan

// Model untuk data user
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImageUrl;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImageUrl,
    required this.createdAt,
  });

  // Factory constructor untuk membuat UserProfile dari data Supabase
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        
        setState(() {
          userProfile = UserProfile.fromJson(response);
          isLoading = false;
        });
      } else {
        // Jika user tidak login, arahkan ke halaman login
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $error')),
        );
      }
    }
  }

  // Method untuk refresh profile setelah edit
  Future<void> _refreshProfile() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserProfile();
  }

  // Method untuk navigasi ke halaman history
  void _navigateToHistory() {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LaporanListPage(),
        ),
      );
    } catch (error) {
      // Jika ada error saat navigasi, tampilkan dialog
      _showErrorDialog('Navigasi Error', 'Tidak dapat membuka halaman riwayat laporan. Error: $error');
    }
  }

  // Method untuk menampilkan error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 172, 172, 172),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 151, 151, 151),
        title: const Text('AKUN', style: TextStyle(color: Colors.white)),
        centerTitle: false,
        elevation: 0,
        // Hapus tombol edit dari AppBar
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userProfile == null
                ? const Center(child: Text('Gagal memuat data profil'))
                : RefreshIndicator(
                    onRefresh: _refreshProfile, // Pull to refresh
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // Untuk refresh indicator
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Profile Picture dengan indicator online
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: userProfile!.profileImageUrl.isNotEmpty && userProfile!.profileImageUrl.startsWith('http')
                                    ? NetworkImage(userProfile!.profileImageUrl)
                                    : userProfile!.profileImageUrl.isNotEmpty && !userProfile!.profileImageUrl.startsWith('http')
                                        ? AssetImage(userProfile!.profileImageUrl) as ImageProvider
                                        : null,
                                backgroundColor: Colors.grey[300],
                                child: userProfile!.profileImageUrl.isEmpty
                                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Username
                          Text(
                            userProfile!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Member sejak ${_formatDate(userProfile!.createdAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Profile Information Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Informasi Pribadi',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoRow(Icons.person, 'Nama Lengkap', userProfile!.name),
                                  _buildInfoRow(Icons.email, 'Email', userProfile!.email),
                                  _buildInfoRow(Icons.phone, 'Nomor Telepon', userProfile!.phone),
                                  _buildInfoRow(Icons.location_on, 'Alamat', userProfile!.address),
                                  _buildInfoRow(Icons.badge, 'ID User', userProfile!.id),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Menu Options
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                // Edit Profil - Menu baru
                                ListTile(
                                  leading: const Icon(Icons.edit, color: Colors.blue),
                                  title: const Text('Edit Profil'),
                                  subtitle: const Text('Ubah informasi pribadi Anda'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: _showEditProfileDialog,
                                ),
                                const Divider(height: 1),
                                // Riwayat Laporan
                                ListTile(
                                  leading: const Icon(Icons.history, color: Colors.orange),
                                  title: const Text('Riwayat Laporan'),
                                  subtitle: const Text('Lihat semua laporan yang pernah dibuat'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: _navigateToHistory,
                                ),
                                const Divider(height: 1),
                                // Bantuan
                                ListTile(
                                  leading: const Icon(Icons.help, color: Colors.green),
                                  title: const Text('Bantuan'),
                                  subtitle: const Text('FAQ dan dukungan pelanggan'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HelpPage(),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 1),
                                // Pengaturan
                                ListTile(
                                  leading: const Icon(Icons.settings, color: Colors.grey),
                                  title: const Text('Pengaturan'),
                                  subtitle: const Text('Pengaturan aplikasi'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    // Panggil halaman SettingsPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SettingsPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Logout Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showLogoutDialog,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Keluar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
      ),
      bottomNavigationBar: const UserBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Belum diisi' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty ? Colors.grey : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Method yang sudah diperbaiki untuk navigasi ke edit profil
  void _showEditProfileDialog() {
    if (userProfile == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          initialData: {
            'id': userProfile!.id,
            'name': userProfile!.name,
            'email': userProfile!.email,
            'phone': userProfile!.phone,
            'address': userProfile!.address,
            'profile_image_url': userProfile!.profileImageUrl,
            'created_at': userProfile!.createdAt.toIso8601String(),
          },
        ),
      ),
    ).then((result) {
      // Jika edit berhasil, reload data profil
      if (result == true) {
        _refreshProfile(); // Refresh data profil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  // Dialog untuk fitur yang akan datang
  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Text(feature),
            ],
          ),
          content: Text('Fitur $feature akan segera tersedia dalam update mendatang.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Konfirmasi Keluar'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                try {
                  // Logout dari Supabase
                  await Supabase.instance.client.auth.signOut();
                  
                  if (mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();
                    
                    // Arahkan ke login page setelah logout
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                } catch (error) {
                  if (mounted) {
                    // Close loading dialog
                    Navigator.of(context).pop();
                    
                    // Show error
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saat logout: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}