import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _nipController = TextEditingController();
  final _departmentController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _selectedDepartment;

  // Daftar departemen/dinas pemerintahan
  final List<String> _departments = [
    'Dinas Pekerjaan Umum',
    'Dinas Kebersihan',
    'Dinas Lingkungan Hidup',
    'Dinas Perhubungan',
    'Dinas Sosial',
    'Dinas Kesehatan',
    'Dinas Pendidikan',
    'Dinas Kependudukan dan Pencatatan Sipil',
    'Bagian Umum',
    'Sekretariat Daerah',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _nipController.dispose();
    _departmentController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final name = _nameController.text.trim();
    final nip = _nipController.text.trim();
    final department = _selectedDepartment ?? '';
    final position = _positionController.text.trim();
    final phone = _phoneController.text.trim();

    // Validasi form lebih ketat untuk admin
    if (name.isEmpty) {
      _showMessage("Nama lengkap harus diisi");
      return;
    }
    if (nip.isEmpty) {
      _showMessage("NIP harus diisi");
      return;
    }
    if (nip.length < 18) {
      _showMessage("NIP harus 18 digit");
      return;
    }
    if (department.isEmpty) {
      _showMessage("Departemen/Dinas harus dipilih");
      return;
    }
    if (position.isEmpty) {
      _showMessage("Jabatan harus diisi");
      return;
    }
    if (phone.isEmpty) {
      _showMessage("Nomor telepon harus diisi");
      return;
    }
    if (email.isEmpty) {
      _showMessage("Email harus diisi");
      return;
    }
    // Validasi email domain pemerintahan
    if (!_isValidGovEmail(email)) {
      _showMessage("Email harus menggunakan domain pemerintahan (contoh: @pemkot.go.id)");
      return;
    }
    if (password.isEmpty) {
      _showMessage("Password harus diisi");
      return;
    }
    if (confirm.isEmpty) {
      _showMessage("Konfirmasi password harus diisi");
      return;
    }
    if (password != confirm) {
      _showMessage("Password tidak cocok");
      return;
    }
    if (password.length < 8) {
      _showMessage("Password minimal 8 karakter untuk admin");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cek apakah NIP sudah terdaftar
      final existingNip = await supabase
          .from('profiles')
          .select('nip')
          .eq('nip', nip)
          .maybeSingle();

      if (existingNip != null) {
        _showMessage("NIP sudah terdaftar dalam sistem");
        setState(() => _isLoading = false);
        return;
      }

      // Daftar akun di Supabase Auth
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final id = res.user?.id;

      if (id != null) {
        // Simpan profil admin dengan data lengkap
        await supabase.from('profiles').insert({
          'id': id,
          'name': name,
          'nip': nip,
          'department': department,
          'position': position,
          'phone': phone,
          'role': 'admin',
          'status': 'pending', // Status pending, menunggu approval super admin
          'created_at': DateTime.now().toIso8601String(),
        });

        // Log aktivitas registrasi admin
        await supabase.from('admin_activities').insert({
          'admin_id': id,
          'activity_type': 'register',
          'description': 'Admin baru mendaftar: $name ($nip)',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      _showSuccessDialog(
        "Berhasil mendaftar sebagai admin!\n\nAkun Anda sedang dalam proses verifikasi. "
        "Tim akan menghubungi Anda dalam 1-3 hari kerja untuk konfirmasi data dan aktivasi akun.\n\n"
        "Silakan cek email untuk verifikasi."
      );

    } on AuthException catch (e) {
      String message;
      
      if (e.message.contains("already registered")) {
        message = "Email sudah terdaftar. Gunakan email lain atau login.";
      } else if (e.message.contains("Password should be")) {
        message = "Password minimal 8 karakter untuk admin.";
      } else if (e.message.contains("Invalid email")) {
        message = "Format email tidak valid.";
      } else {
        message = "Gagal mendaftar: ${e.message}";
      }
      
      _showMessage(message);
    } on PostgrestException catch (e) {
      _showMessage("Gagal simpan profil: ${e.message}");
    } catch (e) {
      _showMessage("Terjadi kesalahan: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isValidGovEmail(String email) {
    // Validasi domain email pemerintahan
    final govDomains = [
      '.go.id',
      '.pemkot.go.id',
      '.pemkab.go.id',
      '.pemprov.go.id',
    ];
    
    return govDomains.any((domain) => email.toLowerCase().endsWith(domain));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Berhasil Mendaftar!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
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
            Positioned.fill(
              child: Image.asset(
                'assets/background/0km.png',
                fit: BoxFit.cover,
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

            Center(
              child: SingleChildScrollView(
                child: Padding(
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
                        // Admin Registration Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[600],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'DAFTAR ADMIN',
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
                          'Daftar Akun Admin',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        
                        // Nama Lengkap
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // NIP
                        TextFormField(
                          controller: _nipController,
                          keyboardType: TextInputType.number,
                          maxLength: 18,
                          decoration: const InputDecoration(
                            labelText: 'NIP (18 digit)*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Departemen/Dinas
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          decoration: const InputDecoration(
                            labelText: 'Departemen/Dinas*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: _departments.map((String dept) {
                            return DropdownMenuItem<String>(
                              value: dept,
                              child: Text(dept, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDepartment = newValue;
                            });
                          },
                        ),
                        const SizedBox(height: 16.0),

                        // Jabatan
                        TextFormField(
                          controller: _positionController,
                          decoration: const InputDecoration(
                            labelText: 'Jabatan*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.work),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Nomor Telepon
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                            hintText: '08xxxxxxxxxx',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email Resmi*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            hintText: 'nama@pemkot.go.id',
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password (min. 8 karakter)*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        // Konfirmasi Password
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Password*',
                            border: UnderlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        
                        // Button Register
                        SizedBox(
                          height: buttonHeight,
                          width: buttonWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                            ),
                            onPressed: _isLoading ? null : _registerAdmin,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text(
                                    'Daftar sebagai Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17.0,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              const TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Login sekarang',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Info admin
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.admin_panel_settings, color: Colors.orange[600], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Akun admin untuk mengelola laporan warga dan memberikan tanggapan resmi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Akun akan diverifikasi dalam 1-3 hari kerja. Gunakan email resmi pemerintahan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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