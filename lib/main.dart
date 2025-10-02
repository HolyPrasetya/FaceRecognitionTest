import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

/// 🔹 Ganti sesuai backend:
/// - Emulator Android → http://10.0.2.2:8000
/// - HP real device (satu WiFi) → http://192.168.10.23:8000
/// - Kalau pakai ngrok → https://xxxx.ngrok.io
// const String apiBase = 'http://192.168.10.23:8000'; //MKOST
const String apiBase = 'http://10.0.2.2:8000'; //BINUS

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Ticketing',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(title: 'Face Ticketing MVP'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  bool _loading = false;
  String _result = '';

  final TextEditingController ticketController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  /// 🔹 Request camera permission
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();

    if (status.isGranted) {
      debugPrint("Camera permission granted");
    } else if (status.isDenied) {
      _showSnackbar("Camera permission denied.");
    } else if (status.isPermanentlyDenied) {
      _showSnackbar("Camera permission permanently denied. Please enable it in settings.");
      openAppSettings();
    }
  }

  /// 🔹 Pick selfie image
  Future<void> pickImage() async {
    await requestCameraPermission();

    final XFile? picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  /// 🔹 Register endpoint
  Future<void> register() async {
    final ticketId = ticketController.text.trim();
    final name = nameController.text.trim();

    if (ticketId.isEmpty || name.isEmpty || _image == null) {
      _showSnackbar("Please provide ticket id, name, and a selfie.");
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final uri = Uri.parse('$apiBase/api/register');
      final request = http.MultipartRequest('POST', uri);
      request.fields['ticket_id'] = ticketId;
      request.fields['name'] = name;
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      setState(() {
        _result = response.body;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// 🔹 Verify endpoint
  Future<void> verify() async {
    if (_image == null) {
      _showSnackbar("Please take a selfie first.");
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final uri = Uri.parse('$apiBase/api/verify');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      setState(() {
        _result = response.body;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackbar(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    ticketController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 260),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Selfie'),
              onPressed: pickImage,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ticketController,
              decoration: const InputDecoration(labelText: 'Ticket ID'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name (for register)'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: register,
                    child: const Text('Register Ticket'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: verify,
                    child: const Text('Verify (Gate)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Result:'),
            ),
            SelectableText(
              _result,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
