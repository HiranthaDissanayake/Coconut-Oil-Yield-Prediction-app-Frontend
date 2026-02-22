import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ════════════════════════════════════════════════════════════
//  PREDICTION PAGE  –  Shows oil mL result to user
//  Weight Input page ලදී images + weight receive කරයි
//  Flask API call කර predicted mL show කරයි
// ════════════════════════════════════════════════════════════

class PredictionPage extends StatefulWidget {
  const PredictionPage({Key? key}) : super(key: key);

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  // ── State ──────────────────────────────────────────────
  bool _isLoading = true;
  String _step    = 'Sending images to server...';
  double _progress = 0.0;
  Map<String, dynamic>? _result;
  String? _error;

  List<File>? _images;
  double?     _weightG;

  // ── Colors ─────────────────────────────────────────────
  static const Color kGreen  = Color(0xFF2E7D32);
  static const Color kLGreen = Color(0xFFE8F5E9);
  static const Color kOrange = Color(0xFFE65100);

  // ── IMPORTANT: Change this URL to your server IP ───────
  // Android emulator ← use 10.0.2.2
  // Real device      ← use your computer's IP, e.g. 192.168.1.5
  static const String kApiUrl = 'http://10.0.2.2:5000';
  // static const String kApiUrl = 'http://192.168.1.5:5000';

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
        _runPrediction();
      } else {
        setState(() {
          _isLoading = false;
          _error = 'No images or weight received.\n'
                   'Images හෝ weight receive නොවුනා.';
        });
      }
    }
  }

  // ── Send images + weight to Flask API ─────────────────
  Future<void> _runPrediction() async {
    try {
      // 1. Encode images as base64
      setState(() { _step = 'Encoding images...'; _progress = 0.20; });
      final List<String> b64List = [];
      for (final file in _images!) {
        final bytes = await file.readAsBytes();
        b64List.add(base64Encode(bytes));
      }

      // 2. Send to Flask
      setState(() { _step = 'Analysing with AI model...'; _progress = 0.55; });
      final response = await http.post(
        Uri.parse('$kApiUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images':   b64List,
          'weight_g': _weightG,
        }),
      ).timeout(const Duration(seconds: 120));

      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}: ${response.body}');
      }

      // 3. Parse result
      setState(() { _step = 'Preparing results...'; _progress = 0.90; });
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() { _isLoading = false; _result = data; });

    } catch (e) {
      setState(() {
        _isLoading = false;
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
      body: _isLoading
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
        const Icon(Icons.eco, size: 72, color: kGreen),
        const SizedBox(height: 32),
        Text(_step, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress, minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
          ),
        ),
        const SizedBox(height: 12),
        Text('${(_progress * 100).toInt()}%',
            style: TextStyle(color: Colors.grey.shade600)),
      ]),
    ),
  );

  // ── Error screen ───────────────────────────────────────
  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 72, color: Colors.red),
        const SizedBox(height: 16),
        const Text('Something went wrong',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(_error ?? '', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Go Back'),
          style: ElevatedButton.styleFrom(
              backgroundColor: kGreen, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
        ),
      ]),
    ),
  );

  // ── Results screen ─────────────────────────────────────
  Widget _buildResults() {
    final r       = _result!;
    final oilMl   = (r['predicted_oil_ml']  as num).toDouble();
    final oilL    = (r['predicted_oil_litres'] as num).toDouble();
    final lowMl   = (r['low_estimate_ml']   as num).toDouble();
    final highMl  = (r['high_estimate_ml']  as num).toDouble();
    final grade   = r['quality_grade'] as String;
    final quality = ((r['quality_score'] as num).toDouble() * 100).toInt();
    final perKg   = (r['oil_per_kg_ml'] as num).toDouble();
    final recs    = (r['recommendations'] as List<dynamic>? ?? [])
                    .map((e) => e.toString()).toList();

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
            '${r['images_analysed']} photos'),
        _infoRow(Icons.fitness_center, 'Copra weight',
            '${((_weightG ?? 0) / 1000).toStringAsFixed(2)} kg  '
            '(${_weightG?.toStringAsFixed(0)} g)'),
        const SizedBox(height: 20),

        // ── Recommendations ───────────────────────────────
        _sectionTitle('Recommendations / නිර්දේශ'),
        const SizedBox(height: 8),
        ...recs.map((rec) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.check_circle, color: kGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(rec,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800,
                    height: 1.4))),
          ]),
        )),
        const SizedBox(height: 28),

        // ── Action buttons ────────────────────────────────
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