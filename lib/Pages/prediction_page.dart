import 'dart:io';
import 'package:flutter/material.dart';

/// Example Prediction Page
/// This page receives the captured images and weight and processes them for ML prediction
class PredictionPage extends StatefulWidget {
  final List<File>? images;
  final double? weight;

  const PredictionPage({Key? key, this.images, this.weight}) : super(key: key);

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  bool _isProcessing = false;
  double _progress = 0.0;
  String _currentStep = '';
  Map<String, dynamic>? _results;

  final Color _primaryGreen = const Color(0xFF6B8E6B);
  final Color _lightGreen = const Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    // Start processing automatically when page loads
    _startPrediction();
  }

  /// Simulate ML prediction process
  Future<void> _startPrediction() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Preprocessing images
      setState(() {
        _currentStep = 'Preprocessing images...';
        _progress = 0.2;
      });
      await Future.delayed(const Duration(seconds: 2));

      // Step 2: Running dryness classification
      setState(() {
        _currentStep = 'Analyzing kernel dryness...';
        _progress = 0.5;
      });
      await Future.delayed(const Duration(seconds: 2));

      // Step 3: Calculating oil yield
      setState(() {
        _currentStep = 'Calculating oil yield...';
        _progress = 0.8;
      });
      await Future.delayed(const Duration(seconds: 2));

      // Step 4: Complete
      setState(() {
        _currentStep = 'Analysis complete!';
        _progress = 1.0;
      });

      // Simulate results
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock results - replace with actual ML model output
      setState(() {
        _isProcessing = false;
        _results = {
          'averageDryness': 85.5,
          'drynessCategory': 'Fully Dried',
          'predictedOilYield': 62.3,
          'confidence': 94.2,
          'qualityGrade': 'A',
          'recommendations': [
            'Kernel dryness is optimal for oil extraction',
            'Expected oil yield is above average',
            'Quality suitable for premium grade coconut oil',
          ],
          'individualDryness': [
            {'image': 1, 'dryness': 87.2},
            {'image': 2, 'dryness': 84.1},
            {'image': 3, 'dryness': 86.3},
            {'image': 4, 'dryness': 83.8},
            {'image': 5, 'dryness': 86.1},
          ],
        };
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Prediction failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get images and weight from navigation arguments if not passed directly
    List<File>? images = widget.images;
    double? weight = widget.weight;
    
    if (images == null || weight == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        images = args['images'] as List<File>?;
        weight = args['weight'] as double?;
      }
    }

    if (images == null || images.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('No images received'),
        ),
      );
    }

    if (weight == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('No weight data received'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _lightGreen,
      appBar: AppBar(
        backgroundColor: _lightGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Oil Yield Prediction',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isProcessing ? _buildProcessingView(images, weight) : _buildResultsView(images, weight),
    );
  }

  /// Processing/Loading view
  Widget _buildProcessingView(List<File> images, double weight) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated processing icon
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.rotate(
                  angle: value * 6.28 * 3, // 3 full rotations
                  child: Icon(
                    Icons.eco,
                    size: 80,
                    color: _primaryGreen.withOpacity(0.7),
                  ),
                );
              },
              onEnd: () {
                // Loop the animation
                setState(() {});
              },
            ),
            const SizedBox(height: 40),
            
            // Sample info
            Text(
              'Processing ${images.length} samples',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sample weight: ${weight.toStringAsFixed(0)} g',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            
            // Progress bar
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            
            // Current step text
            Text(
              _currentStep,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            
            // Progress percentage
            Text(
              '${(_progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Results view after processing
  Widget _buildResultsView(List<File> images, double weight) {
    if (_results == null) {
      return const Center(child: Text('No results available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sample info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.photo_library,
                  '${images.length} Samples',
                  Colors.blue,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                _buildInfoItem(
                  Icons.fitness_center,
                  '${weight.toStringAsFixed(0)} g',
                  Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main result card
          _buildResultCard(
            'Predicted Oil Yield',
            '${_results!['predictedOilYield']}%',
            Icons.water_drop,
            Colors.blue,
          ),
          const SizedBox(height: 16),

          // Dryness level card
          _buildResultCard(
            'Average Kernel Dryness',
            '${_results!['averageDryness']}%',
            Icons.wb_sunny,
            Colors.orange,
          ),
          const SizedBox(height: 16),

          // Quality grade card
          _buildResultCard(
            'Quality Grade',
            _results!['qualityGrade'],
            Icons.star,
            Colors.amber,
          ),
          const SizedBox(height: 16),

          // Confidence card
          _buildResultCard(
            'Prediction Confidence',
            '${_results!['confidence']}%',
            Icons.analytics,
            Colors.purple,
          ),
          const SizedBox(height: 24),

          // Recommendations section
          const Text(
            'Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...(_results!['recommendations'] as List).map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: _primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Individual image analysis
          const Text(
            'Individual Sample Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...(_results!['individualDryness'] as List).asMap().entries.map(
            (entry) => _buildImageAnalysisCard(
              images[entry.key],
              entry.value['image'],
              entry.value['dryness'],
            ),
          ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Export or share results
                    _exportResults();
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Results'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryGreen,
                    side: BorderSide(color: _primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Go back to home or start new prediction
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisCard(File image, int imageNum, double dryness) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              image,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sample #$imageNum',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dryness.toStringAsFixed(1)}% dry',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: dryness / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    dryness > 80 ? Colors.green : Colors.orange,
                  ),
                  strokeWidth: 4,
                ),
                Text(
                  '${dryness.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _exportResults() {
    // Implement export/share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Results exported successfully'),
        backgroundColor: _primaryGreen,
      ),
    );
  }
}