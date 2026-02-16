import 'dart:io';
import 'package:flutter/material.dart';

class WeightInputPage extends StatefulWidget {
  const WeightInputPage({Key? key}) : super(key: key);

  @override
  State<WeightInputPage> createState() => _WeightInputPageState();
}

class _WeightInputPageState extends State<WeightInputPage> {
  List<File>? _images;
  double _weight = 350.0; // Default weight in grams
  final double _minWeight = 50.0;
  final double _maxWeight = 5000.0;
  final double _stepSize = 10.0;
  bool _isInitialized = false;

  // Color scheme
  final Color _primaryGreen = const Color(0xFF6B8E6B);
  final Color _lightGreen = const Color(0xFFE8F5E9);
  final Color _creamBackground = const Color(0xFFF8F4E1);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Extract images from route arguments only once
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args != null) {
        if (args is List<File>) {
          _images = args;
        } else if (args is List) {
          try {
            _images = List<File>.from(args);
          } catch (e) {
            debugPrint('Error converting arguments to List<File>: $e');
          }
        }
      }
      
      _isInitialized = true;
      setState(() {}); // Trigger rebuild with images
    }
  }

  // Increment weight
  void _incrementWeight() {
    setState(() {
      if (_weight < _maxWeight) {
        _weight += _stepSize;
      }
    });
  }

  // Decrement weight
  void _decrementWeight() {
    setState(() {
      if (_weight > _minWeight) {
        _weight -= _stepSize;
      }
    });
  }

  // Analyze - proceed to prediction
  void _analyze() {
    if (_images == null || _images!.isEmpty) {
      _showSnackBar('No images available', isError: true);
      return;
    }

    if (_weight < _minWeight) {
      _showSnackBar('Please enter a valid weight', isError: true);
      return;
    }

    // Navigate to prediction page with images and weight
    Navigator.pushNamed(
      context,
      '/prediction',
      arguments: {
        'images': _images,
        'weight': _weight,
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show error screen if no images
    if (_isInitialized && (_images == null || _images!.isEmpty)) {
      return _buildErrorScreen();
    }

    // Show loading while initializing
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Main content
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Coconut icon
            Image.asset(
              'assets/coconut_icon.png',
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
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Input Sample Weight',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Input the total weight of the coconut kernel pieces.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              // Weight Input Card (Cream Background)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _creamBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Weight icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Weight display
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_weight.toStringAsFixed(0)} g',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Decrement button
                    _buildWeightButton(
                      icon: Icons.remove,
                      onPressed: _decrementWeight,
                      enabled: _weight > _minWeight,
                    ),
                    const SizedBox(width: 8),

                    // Increment button
                    _buildWeightButton(
                      icon: Icons.add,
                      onPressed: _incrementWeight,
                      enabled: _weight < _maxWeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Analyze Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Analyze',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Alternative Weight Input (Green Background)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_weight.toStringAsFixed(0)} g',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildCompactWeightButton(
                              icon: Icons.add,
                              onPressed: _incrementWeight,
                              enabled: _weight < _maxWeight,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Slider for fine adjustment
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: _primaryGreen,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: _primaryGreen,
                        overlayColor: _primaryGreen.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _weight,
                        min: _minWeight,
                        max: _maxWeight,
                        divisions: ((_maxWeight - _minWeight) / _stepSize).toInt(),
                        label: '${_weight.toStringAsFixed(0)} g',
                        onChanged: (value) {
                          setState(() {
                            _weight = value;
                          });
                        },
                      ),
                    ),

                    // Min/Max labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_minWeight.toInt()} g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_maxWeight.toInt()} g',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Secondary Analyze button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Analyze',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Accurate weight measurement improves prediction accuracy. Use a digital scale for best results.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sample count info
              if (_images != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_images!.length} kernel samples captured',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Error screen widget
  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _lightGreen,
        title: const Text('Error'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                'No Images Received',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Please go back and select 5-10 coconut kernel sample images.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Go Back to Image Capture',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Weight adjustment button
  Widget _buildWeightButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return Material(
      color: enabled ? _primaryGreen : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey.shade500,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Compact weight button for alternative layout
  Widget _buildCompactWeightButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool enabled,
  }) {
    return Material(
      color: enabled ? _primaryGreen : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.grey.shade500,
            size: 20,
          ),
        ),
      ),
    );
  }
}