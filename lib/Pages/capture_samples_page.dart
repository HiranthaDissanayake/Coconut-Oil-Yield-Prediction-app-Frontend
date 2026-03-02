import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CaptureSamplesPage extends StatefulWidget {
  const CaptureSamplesPage({Key? key}) : super(key: key);

  @override
  State<CaptureSamplesPage> createState() => _CaptureSamplesPageState();
}

class _CaptureSamplesPageState extends State<CaptureSamplesPage> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final int _minImages = 5;
  final int _maxImages = 10;
  final Color _primaryGreen = const Color(0xFF6B8E6B);
  final Color _lightGreen = const Color(0xFFE8F5E9);
  bool _showExamples = true;  // NEW: Toggle examples

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (photo != null) {
        setState(() {
          if (_selectedImages.length < _maxImages) {
            _selectedImages.add(File(photo.path));
          } else {
            _showSnackBar('Maximum $_maxImages images allowed', isError: true);
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e', isError: true);
    }
  }

  Future<void> _uploadImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (images.isNotEmpty) {
        setState(() {
          for (var image in images) {
            if (_selectedImages.length < _maxImages) {
              _selectedImages.add(File(image.path));
            } else {
              _showSnackBar('Maximum $_maxImages images allowed', isError: true);
              break;
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error uploading images: $e', isError: true);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _proceedToNext() {
    if (_selectedImages.length < _minImages) {
      _showSnackBar('Please select at least $_minImages images', isError: true);
      return;
    }
    Navigator.pushNamed(context, '/weight-input', arguments: _selectedImages);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _primaryGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreen,
      appBar: AppBar(
        backgroundColor: _lightGreen,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/coconut_icon.png', height: 32, width: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.eco, color: Color(0xFF6B8E6B), size: 32)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Coconut Oil Yield\nPrediction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                  color: Colors.black87, height: 1.2)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF6B8E6B)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Capture Coconut\nCopra Samples',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.black87, height: 1.2)),
              const SizedBox(height: 16),
              Text('Take or upload 5-10 clear images of dried coconut copra pieces.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4)),
              const SizedBox(height: 24),

              // ═══ NEW: EXAMPLE IMAGES SECTION ═══
              _buildExampleSection(),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedImages.length >= _minImages
                      ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${_selectedImages.length}/$_maxImages images selected',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                    color: _selectedImages.length >= _minImages
                        ? Colors.green.shade800 : Colors.orange.shade800)),
              ),
              const SizedBox(height: 16),

              // Image grid (same as before)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 12,
                  mainAxisSpacing: 12, childAspectRatio: 1,
                ),
                itemCount: _selectedImages.length < _maxImages
                    ? _selectedImages.length + 1 : _selectedImages.length,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length && _selectedImages.length < _maxImages) {
                    return GestureDetector(
                      onTap: _uploadImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add, size: 48, color: Colors.grey),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(_selectedImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Buttons (same as before)
              SizedBox(width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text('Take Photo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen, foregroundColor: Colors.white,
                    elevation: 2, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: _uploadImages,
                  icon: const Icon(Icons.upload, size: 24),
                  label: const Text('Upload Images',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen, foregroundColor: Colors.white,
                    elevation: 2, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _proceedToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen, foregroundColor: Colors.white,
                    elevation: 3, shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
                  child: const Text('Next',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  NEW METHODS: Build example section
  // ═══════════════════════════════════════════════════════════

  Widget _buildExampleSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        children: [
          // Collapsible header
          InkWell(
            onTap: () => setState(() => _showExamples = !_showExamples),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.photo_library_outlined, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Photography Tips', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900)),
                        Text('Learn how to take good copra photos',
                          style: TextStyle(fontSize: 13, color: Colors.blue.shade700)),
                      ],
                    ),
                  ),
                  Icon(_showExamples ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.blue.shade700),
                ],
              ),
            ),
          ),
          // Content (collapsible)
          if (_showExamples) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 4 visual tips
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _exampleCard(Icons.wb_sunny, 'Good Lighting', 'Natural daylight', Colors.orange),
                      _exampleCard(Icons.center_focus_strong, 'Close Up', 'Fill the frame', Colors.green),
                      _exampleCard(Icons.layers, 'Plain Background', 'Black or simple', Colors.blue),
                      _exampleCard(Icons.texture, 'Show Texture', 'Surface detail', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Best practices & avoid
                  _buildTips(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _exampleCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text('Best Practices', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold,
                color: Colors.green.shade900)),
            ],
          ),
          const SizedBox(height: 12),
          _tip('✓', 'Use good lighting (daylight best)'),
          _tip('✓', 'Get close to copra pieces'),
          _tip('✓', 'Plain background'),
          _tip('✓', 'Different angles'),
          _tip('✓', 'Keep copra in focus'),
          const SizedBox(height: 8),
          Divider(color: Colors.green.shade300),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.cancel, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text('Avoid', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold,
                color: Colors.red.shade900)),
            ],
          ),
          const SizedBox(height: 12),
          _tip('✗', 'Dark or poor lighting', true),
          _tip('✗', 'Blurry images', true),
          _tip('✗', 'Too far from camera', true),
          _tip('✗', 'Busy backgrounds', true),
        ],
      ),
    );
  }

  Widget _tip(String bullet, String text, [bool avoid = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bullet, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
            color: avoid ? Colors.red.shade700 : Colors.green.shade700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13,
              color: avoid ? Colors.red.shade800 : Colors.green.shade800, height: 1.3)),
          ),
        ],
      ),
    );
  }
}