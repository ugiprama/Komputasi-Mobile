import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Status mode gelap dan notifikasi disimpan secara lokal
  bool _isDarkMode = false;
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color.fromRGBO(123, 195, 166, 1),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader('Tampilan'),
          _buildSwitchListTile(
            title: 'Mode Gelap',
            icon: Icons.dark_mode,
            value: _isDarkMode, // Menggunakan state lokal
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
                // Tanpa Provider, perubahan tema hanya akan terjadi pada widget ini.
                // Untuk menerapkan perubahan ke seluruh aplikasi, Anda memerlukan manajemen state global.
              });
            },
          ),
          _buildDivider(),
          _buildHeader('Notifikasi'),
          _buildSwitchListTile(
            title: 'Aktifkan Notifikasi',
            icon: Icons.notifications,
            value: _isNotificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _isNotificationsEnabled = value;
                // Logika untuk mengaktifkan/menonaktifkan notifikasi
              });
            },
          ),
          _buildDivider(),
          _buildHeader('Umum'),
          _buildListTile(
            title: 'Bahasa',
            subtitle: 'Indonesia',
            icon: Icons.language,
            onTap: () {
              // Aksi saat item Bahasa diklik
              _showLanguageBottomSheet(context);
            },
          ),
          _buildListTile(
            title: 'Tentang Aplikasi',
            icon: Icons.info_outline,
            onTap: () {
              // Aksi saat item Tentang Aplikasi diklik
              _showAboutDialog(context);
            },
          ),
          _buildListTile(
            title: 'Kebijakan Privasi',
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              // Aksi untuk membuka halaman kebijakan privasi
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
      activeColor: const Color.fromARGB(255, 115, 179, 159),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: Icon(icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Column(
            children: [
              ListTile(
                title: const Text('Indonesia'),
                leading: const Icon(Icons.check),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('English'),
                leading: const Icon(Icons.language),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'LAPOR WARGA',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.apps),
      children: [
        const Text(
          'Aplikasi ini dibuat untuk membantu pengguna dalam melaporkan fasilitas umum dan fasilitas penunjang warga lainnya.',
        ),
      ],
    );
  }
}