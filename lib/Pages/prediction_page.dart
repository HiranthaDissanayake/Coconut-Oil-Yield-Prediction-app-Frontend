import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════
//  PREDICTION PAGE with IMAGE VALIDATION
//  Validates copra images before prediction
//  Copra images validate කරයි prediction පෙර
// ════════════════════════════════════════════════════════════

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  // ── State ──────────────────────────────────────────────
  bool _isLoading = true;
  bool _isValidating = false;
  String _step    = 'Validating images...';
  double _progress = 0.0;
  Map<String, dynamic>? _result;
  String? _error;
  List<Map<String, dynamic>>? _invalidImages;  // NEW: Track invalid images

  List<File>? _images;
  double?     _weightG;

  // ── Colors ─────────────────────────────────────────────
  static const Color kGreen  = Color(0xFF2E7D32);
  static const Color kLGreen = Color(0xFFE8F5E9);
  static const Color kOrange = Color(0xFFE65100);
  static const Color kRed    = Color(0xFFB71C1C);
  static const Color kLRed   = Color(0xFFFFEBEE);

  static const String kApiUrl = 'http://10.151.29.38:5000';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_images == null) {
      final args = ModalRoute.of(context)?.settings.arguments
          as Map<String, dynamic>?;
      if (args != null) {
        _images  = args['images'] as List<File>?;
        _weightG = (args['weight'] as num?)?.toDouble();
      }
      if (_images != null && _weightG != null) {
        _validateAndPredict();  // NEW: Validate first!
      } else {
        setState(() {
          _isLoading = false;
          _error = 'No images or weight received.\n'
                   'Images හෝ weight receive නොවුනා.';
        });
      }
    }
  }

  // ══════════════════════════════════════════════════════════
  //  NEW: VALIDATE IMAGES FIRST, THEN PREDICT
  // ══════════════════════════════════════════════════════════
  Future<void> _validateAndPredict() async {
    try {
      // 1. Encode images
      setState(() { 
        _step = 'Encoding images...'; 
        _progress = 0.10;
        _isValidating = true; 
      });
      
      final List<String> b64List = [];
      for (final file in _images!) {
        final bytes = await file.readAsBytes();
        b64List.add(base64Encode(bytes));
      }

      // 2. VALIDATE images with new endpoint
      setState(() { 
        _step = 'Validating copra images...'; 
        _progress = 0.30;
      });
      
      final validateResponse = await http.post(
        Uri.parse('$kApiUrl/validate_images'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'images': b64List}),
      ).timeout(const Duration(seconds: 60));

      if (validateResponse.statusCode != 200) {
        throw Exception('Validation failed: ${validateResponse.body}');
      }

      final validateData = jsonDecode(validateResponse.body) as Map<String, dynamic>;
      final allValid = validateData['all_valid'] as bool;

      // If NOT all valid, show error
      if (!allValid) {
        final validations = validateData['validations'] as List<dynamic>;
        final invalidImgs = validations
            .where((v) => !(v['is_copra'] as bool))
            .map((v) => {
                  'index': v['image_index'] as int,
                  'reason': v['reason'] as String,
                  'confidence': (v['confidence'] as num).toDouble(),
                })
            .toList();

        setState(() {
          _isLoading = false;
          _isValidating = false;
          _invalidImages = invalidImgs;
          _error = 'Some images are not coconut copra!\n'
                   'සමහර images coconut copra නොවේ!\n\n'
                   'Please use only dried copra photos.';
        });
        return;
      }

      // 3. All valid! Proceed with prediction
      setState(() { 
        _step = 'Analysing with AI model...'; 
        _progress = 0.60;
        _isValidating = false; 
      });

      final response = await http.post(
        Uri.parse('$kApiUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images':   b64List,
          'weight_g': _weightG,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        // Check if it's an invalid_images error
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] == 'invalid_images') {
            final invalidImgs = (errorData['invalid_images'] as List)
                .map((v) => {
                      'index': v['index'] as int,
                      'reason': v['reason'] as String,
                      'confidence': (v['confidence'] as num).toDouble(),
                    })
                .toList();
            
            setState(() {
              _isLoading = false;
              _invalidImages = invalidImgs;
              _error = errorData['message_si'] ?? errorData['message'];
            });
            return;
          }
        } catch (_) {}
        
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }

      // 4. Parse result
      setState(() { _step = 'Preparing results...'; _progress = 0.90; });
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      print('API Response: $data');

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() { _isLoading = false; _result = data; });

    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _isValidating = false;
        _error = 'Failed to connect to server.\n'
                 'Server connect කළ නොහැකිවිය.\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLGreen,
      appBar: _buildAppBar(),
      body: _isLoading || _isValidating
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _buildResults(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: kLGreen,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black87),
      onPressed: () => Navigator.pop(context),
    ),
    title: Row(children: [
      const Icon(Icons.eco, color: kGreen, size: 28),
      const SizedBox(width: 8),
      const Expanded(
        child: Text('Oil Yield Prediction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: Colors.black87)),
      ),
    ]),
  );

  // ── Loading screen ─────────────────────────────────────
  Widget _buildLoading() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          _isValidating ? Icons.verified_user : Icons.eco, 
          size: 72, 
          color: _isValidating ? kOrange : kGreen
        ),
        const SizedBox(height: 32),
        Text(_step, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress, minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              _isValidating ? kOrange : kGreen
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('${(_progress * 100).toInt()}%',
            style: TextStyle(color: Colors.grey.shade600)),
      ]),
    ),
  );

  // ══════════════════════════════════════════════════════════
  //  NEW: ENHANCED ERROR SCREEN with Invalid Images List
  // ══════════════════════════════════════════════════════════
  Widget _buildError() {
    final hasInvalidImages = _invalidImages != null && _invalidImages!.isNotEmpty;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          hasInvalidImages ? Icons.image_not_supported : Icons.error_outline, 
          size: 72, 
          color: hasInvalidImages ? kOrange : Colors.red
        ),
        const SizedBox(height: 16),
        Text(
          hasInvalidImages 
            ? 'Invalid Images Detected' 
            : 'Something went wrong',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(_error ?? '', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700)),
        
        // NEW: Show which images are invalid
        if (hasInvalidImages) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kLRed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kRed.withOpacity(0.3)),
            ),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.warning_amber, color: kRed, size: 24),
                const SizedBox(width: 8),
                const Text('Invalid Images:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              
              ..._invalidImages!.map((invalid) {
                final index = invalid['index'] as int;
                final reason = invalid['reason'] as String;
                final conf = ((invalid['confidence'] as double) * 100).toInt();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: kRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text('$index',
                              style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Image #$index',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(reason,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                            Text('Confidence: $conf%',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tip: Take photos of dried coconut copra pieces only, in good lighting.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ]),
          ),
        ],
        
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: Text(
              hasInvalidImages 
                ? 'Retake Photos / යළි Photos ගන්න' 
                : 'Go Back',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasInvalidImages ? kOrange : kGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Results screen (same as before with NULL safety) ──
  Widget _buildResults() {
    final r = _result!;
    
    final oilMl = _getDouble(r, 'predicted_oil_ml', 0.0);
    final oilL = _getDouble(r, 'predicted_oil_litres', oilMl / 1000);
    final lowMl = _getDouble(r, 'low_estimate_ml', oilMl * 0.9);
    final highMl = _getDouble(r, 'high_estimate_ml', oilMl * 1.1);
    final grade = _getString(r, 'quality_grade', 'N/A');
    final qualityScore = _getDouble(r, 'quality_score', 0.0);
    final quality = (qualityScore * 100).toInt();
    final perKg = _getDouble(r, 'oil_per_kg_ml', 0.0);
    final imagesAnalysed = _getInt(r, 'images_analysed', _images?.length ?? 0);
    
    final recs = (r['recommendations'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Main result card ─────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kGreen, Color(0xFF43A047)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: kGreen.withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6),
            )],
          ),
          child: Column(children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 48),
            const SizedBox(height: 12),
            const Text('Predicted Oil Yield',
                style: TextStyle(color: Colors.white70, fontSize: 15)),
            const Text('Predicted Oil Yield / අපේක්ෂිත Oil ප්‍රමාණය',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12)),
            const SizedBox(height: 8),
            Text('${oilMl.toStringAsFixed(0)} mL',
                style: const TextStyle(color: Colors.white,
                    fontSize: 52, fontWeight: FontWeight.bold)),
            Text('≈ ${oilL.toStringAsFixed(2)} litres',
                style: const TextStyle(color: Colors.white70, fontSize: 18)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text('Range: ${lowMl.toStringAsFixed(0)} – ${highMl.toStringAsFixed(0)} mL',
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Stats row ────────────────────────────────────
        Row(children: [
          Expanded(child: _statCard('Grade', grade, Icons.star,
              grade == 'A' ? Colors.amber : grade == 'B' ? Colors.blue : kOrange)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Quality', '$quality%', Icons.verified,
              Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Per kg', '${perKg.toStringAsFixed(0)} mL',
              Icons.scale, Colors.purple)),
        ]),
        const SizedBox(height: 20),

        // ── Input summary ─────────────────────────────────
        _sectionTitle('Your Input / ඔබ ලබාදුන් Data'),
        const SizedBox(height: 8),
        _infoRow(Icons.photo_library, 'Images analysed',
            '$imagesAnalysed photos'),
        _infoRow(Icons.fitness_center, 'Copra weight',
            '${((_weightG ?? 0) / 1000).toStringAsFixed(2)} kg  '
            '(${_weightG?.toStringAsFixed(0)} g)'),
        const SizedBox(height: 20),

        // ── Recommendations ───────────────────────────────
        _sectionTitle('Recommendations / නිර්දේශ'),
        const SizedBox(height: 8),
        
        if (recs.isNotEmpty)
          ...recs.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle, color: kGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(rec,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800,
                      height: 1.4))),
            ]),
          ))
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline, color: kGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(
                'Results ready! Check the predicted oil yield above.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
              )),
            ]),
          ),
        
        const SizedBox(height: 28),

        // ── Action button ─────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (r) => r.isFirst),
            icon: const Icon(Icons.home),
            label: const Text('New Prediction / නව Prediction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  // ── Helper functions for NULL safety ──────────────────
  double _getDouble(Map<String, dynamic> map, String key, double defaultValue) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  int _getInt(Map<String, dynamic> map, String key, int defaultValue) {
    final value = map[key];
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  String _getString(Map<String, dynamic> map, String key, String defaultValue) {
    final value = map[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  Widget _statCard(String label, String value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8, offset: const Offset(0, 3),
          )],
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ]),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, color: kGreen, size: 22),
      const SizedBox(width: 10),
      Text('$label: ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
    ]),
  );

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
          color: Colors.black87));
}