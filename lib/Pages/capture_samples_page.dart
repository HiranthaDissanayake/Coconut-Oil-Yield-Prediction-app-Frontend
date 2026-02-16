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

  // Color scheme matching the app design
  final Color _primaryGreen = const Color(0xFF6B8E6B);
  final Color _lightGreen = const Color(0xFFE8F5E9);

  // Take photo using camera
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
            _showSnackBar(
              'Maximum $_maxImages images allowed',
              isError: true,
            );
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e', isError: true);
    }
  }

  // Upload images from gallery
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
              _showSnackBar(
                'Maximum $_maxImages images allowed',
                isError: true,
              );
              break;
            }
          }
        });
      }
    } catch (e) {
      _showSnackBar('Error uploading images: $e', isError: true);
    }
  }

  // Remove image from selection
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Validate and proceed to next screen
  void _proceedToNext() {
    if (_selectedImages.length < _minImages) {
      _showSnackBar(
        'Please select at least $_minImages images to continue',
        isError: true,
      );
      return;
    }

    // Navigate to weight input screen
    Navigator.pushNamed(
      context,
      '/weight-input',
      arguments: _selectedImages,
    );
  }

  // Show snackbar message
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
            // Coconut icon
            Image.asset(
              'assets/coconut_icon.png', // Replace with your asset path
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.eco,
                  color: Color(0xFF6B8E6B),
                  size: 32,
                );
              },
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Coconut Oil Yield\nPrediction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF6B8E6B)),
            onPressed: () {
              // Open menu/drawer
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Text(
                'Capture Coconut\nCopra Samples',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'Take or upload 5-10 clear images of partially dried or fully dried coconut kernel pieces for',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'analysis.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Image Count Indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _selectedImages.length >= _minImages
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedImages.length}/$_maxImages images selected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedImages.length >= _minImages
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Image Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _selectedImages.length < _maxImages
                    ? _selectedImages.length + 1
                    : _selectedImages.length,
                itemBuilder: (context, index) {
                  // Add Image Button (last item)
                  if (index == _selectedImages.length &&
                      _selectedImages.length < _maxImages) {
                    return GestureDetector(
                      onTap: _uploadImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  // Image Preview
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
                      // Remove button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Take Photo Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, size: 24),
                  label: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Upload Images Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _uploadImages,
                  icon: const Icon(Icons.upload, size: 24),
                  label: const Text(
                    'Upload Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _proceedToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}