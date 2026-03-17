import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static String get _apiBaseUrl => AppConfig.apiBaseUrl;
  static String get _serverBaseUrl => AppConfig.serverBaseUrl;

  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _profileImageUrl;
  File? _pickedImageFile;
  bool _removeProfileImage = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _resolveImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return '$_serverBaseUrl$imagePath';
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();

    if (!mounted) {
      return;
    }

    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _user = user;
      _nameController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
      _bioController.text = user['bio'] ?? '';
      _phoneController.text = user['phone'] ?? '';
      _locationController.text = user['location'] ?? '';
      _profileImageUrl = user['profile_image'];
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _pickedImageFile = File(picked.path);
      _removeProfileImage = false;
    });
  }

  void _clearImage() {
    setState(() {
      _pickedImageFile = null;
      _profileImageUrl = null;
      _removeProfileImage = true;
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Kies uit galerij'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Maak een foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_pickedImageFile != null ||
                  (_profileImageUrl != null && _profileImageUrl!.isNotEmpty))
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Verwijder foto'),
                  onTap: () {
                    Navigator.pop(context);
                    _clearImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/users/${_user!['id']}'),
      );

      request.fields['_method'] = 'PUT';
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['bio'] = _bioController.text.trim();
      request.fields['phone'] = _phoneController.text.trim();
      request.fields['location'] = _locationController.text.trim();

      if (_passwordController.text.isNotEmpty) {
        request.fields['password'] = _passwordController.text;
      }

      if (_removeProfileImage) {
        request.fields['remove_profile_image'] = '1';
      }

      if (_pickedImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image_file',
            _pickedImageFile!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? json.decode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Profiel bijwerken mislukt');
      }

      await _authService.setCurrentUser(data['user']);

      if (mounted) {
        setState(() {
          _user = data['user'];
          _profileImageUrl = _user?['profile_image'];
          _pickedImageFile = null;
          _removeProfileImage = false;
        });

        _passwordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profiel bijgewerkt!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mijn Profiel')),
        body: const Center(child: Text('Geen ingelogde gebruiker gevonden.')),
      );
    }

    final currentImage = _pickedImageFile != null
        ? FileImage(_pickedImageFile!) as ImageProvider
        : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
        ? NetworkImage(_resolveImageUrl(_profileImageUrl!))
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'Mijn Profiel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _showImageOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: currentImage,
                      child: currentImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Klik om je eigen profielfoto te uploaden',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vul je naam in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vul je email in';
                  }
                  if (!value.contains('@')) {
                    return 'Vul een geldig email adres in';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefoon (optioneel)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Locatie (optioneel)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 1000,
                decoration: const InputDecoration(
                  labelText: 'Over mij',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.info_outline),
                  hintText: 'Vertel iets over jezelf... ',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nieuw wachtwoord (optioneel)',
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Laat leeg om niet te wijzigen',
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _user?['role'] == 'admin'
                      ? Colors.orange.shade100
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _user?['role'] == 'admin'
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      size: 20,
                      color: _user?['role'] == 'admin'
                          ? Colors.orange.shade900
                          : Colors.blue.shade900,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _user?['role'] == 'admin' ? 'Admin Account' : 'Gebruiker',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _user?['role'] == 'admin'
                            ? Colors.orange.shade900
                            : Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _updateProfile,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Profiel Opslaan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
