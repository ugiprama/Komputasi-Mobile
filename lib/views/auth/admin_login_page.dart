import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:applaporwarga/views/admin/home_admin_page.dart'; // Nanti buat halaman ini
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _adminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi form kosong
    if (email.isEmpty && password.isEmpty) {
      _showModernDialog("Form Tidak Lengkap", "Email dan password harus diisi.");
      return;
    }
    if (email.isEmpty) {
      _showModernDialog("Email Kosong", "Silakan masukkan email admin Anda.");
      return;
    }
    if (password.isEmpty) {
      _showModernDialog("Password Kosong", "Silakan masukkan password admin Anda.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login dengan Supabase Auth
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null && res.user!.emailConfirmedAt == null) {
        await supabase.auth.signOut();
        _showModernDialog(
          "Email Belum Diverifikasi",
          "Silakan periksa email Anda untuk verifikasi sebelum login.",
        );
        return;
      }

      if (res.user == null) {
        _showModernDialog(
          "Login Gagal",
          "Email atau password salah.",
        );
        return;
      }

      // Cek apakah user adalah admin
      final userProfile = await supabase
          .from('profiles')
          .select('role')
          .eq('id', res.user!.id)
          .single();

      if (userProfile['role'] != 'admin' && userProfile['role'] != 'super_admin') {
        await supabase.auth.signOut();
        _showModernDialog(
          "Akses Ditolak",
          "Anda tidak memiliki akses admin. Gunakan aplikasi warga untuk login sebagai pengguna biasa.",
        );
        return;
      }

      // Jika berhasil dan adalah admin, navigasi ke dashboard admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdminPage()),
      );

    } on AuthException catch (e) {
      String message;

      if (e.message.contains("Invalid login credentials")) {
        message = "Email atau password admin salah.";
      } else if (e.message.contains("Email not confirmed")) {
        message = "Email admin belum dikonfirmasi. Periksa Gmail Anda.";
      } else if (e.message.contains("network") || e.message.contains("timeout")) {
        message = "Koneksi internet bermasalah. Periksa jaringan Anda.";
      } else {
        message = "Terjadi kesalahan saat login admin. Silakan coba lagi.";
      }

      _showModernDialog("Login Admin Gagal", message);

    } catch (e) {
      _showModernDialog("Error", "Terjadi kesalahan tak terduga. Silakan coba lagi.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showModernDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title.contains("Gagal") || title.contains("Error") || title.contains("Ditolak") 
                    ? Icons.error 
                    : Icons.info, 
                size: 48, 
                color: title.contains("Gagal") || title.contains("Error") || title.contains("Ditolak") 
                    ? Colors.red 
                    : Colors.blue
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double buttonHeight = 48.0;
    const double buttonWidth = double.infinity;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/background/0km.png',
                fit: BoxFit.cover,
              ),
            ),

            // Logo
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/logo/lapor_warga.png',
                  width: 120,
                  height: 120,
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),

            // Login box
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Admin Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ADMIN LOGIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      const Text(
                        'Login Admin',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Admin',
                          border: UnderlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password Admin',
                          border: const UnderlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Tombol Login Admin
                      SizedBox(
                        height: buttonHeight,
                        width: buttonWidth,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _isLoading ? null : _adminLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'Login sebagai Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.0,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // Link kembali ke user login
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          children: [
                            const TextSpan(text: 'Bukan admin? '),
                            TextSpan(
                              text: 'Login sebagai warga',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/user-auth');
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}