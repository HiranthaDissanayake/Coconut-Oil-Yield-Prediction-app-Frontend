import 'package:coconut_oil_prediction_app/Pages/capture_samples_page.dart';
import 'package:coconut_oil_prediction_app/Pages/prediction_page.dart';
import 'package:coconut_oil_prediction_app/Pages/weight_input_page.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const CoconutOilPredictionApp());
}

class CoconutOilPredictionApp extends StatelessWidget {
  const CoconutOilPredictionApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coconut Oil Yield Prediction',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF6B8E6B),
        scaffoldBackgroundColor: const Color(0xFFE8F5E9),
        fontFamily: 'Roboto',
        useMaterial3: true,
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      
      // Define named routes
      routes: {
        '/': (context) => const HomePage(),
        '/capture': (context) => const CaptureSamplesPage(),
        '/weight-input': (context) => const WeightInputPage(),
        '/prediction': (context) => const PredictionPage(),
      },
      initialRoute: '/',
    );
  }
}

/// Home Page - Entry point of the app
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  final Color _primaryGreen = const Color(0xFF6B8E6B);
  final Color _lightGreen = const Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.eco,
                  size: 80,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 40),

              // App Title
              const Text(
                'Coconut Oil Yield\nPrediction',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // App Description
              Text(
                'AI-powered tool to predict coconut oil yield based on kernel dryness analysis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 60),

              // Start Prediction Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/capture');
                  },
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: const Text(
                    'Start Prediction',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // How it works button
              OutlinedButton.icon(
                onPressed: () {
                  _showHowItWorksDialog(context);
                },
                icon: const Icon(Icons.info_outline),
                label: const Text(
                  'How it works',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryGreen,
                  side: BorderSide(color: _primaryGreen, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Features list
              _buildFeatureItem(
                Icons.photo_camera,
                'Capture or Upload Images',
                'Take photos or upload 5-10 kernel samples',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.analytics,
                'AI Analysis',
                'Advanced CNN model analyzes dryness levels',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                Icons.insights,
                'Instant Results',
                'Get oil yield prediction in seconds',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
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
          child: Icon(icon, color: _primaryGreen, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showHowItWorksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'How It Works',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStep('1', 'Capture Samples',
                  'Take or upload 5-10 clear images of coconut kernel pieces'),
              const SizedBox(height: 16),
              _buildStep('2', 'AI Processing',
                  'Our CNN model analyzes dryness levels of each sample'),
              const SizedBox(height: 16),
              _buildStep('3', 'Yield Calculation',
                  'Regression model predicts oil yield percentage'),
              const SizedBox(height: 16),
              _buildStep('4', 'Get Results',
                  'Receive detailed predictions and recommendations'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}