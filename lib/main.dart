import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'My 3D Engine Pro',
      debugShowCheckedModeBanner: false,
      home: EngineScreen(),
    );
  }
}

class EngineScreen extends StatefulWidget {
  const EngineScreen({super.key});

  @override
  State<EngineScreen> createState() => _EngineScreenState();
}

class _EngineScreenState extends State<EngineScreen> {
  late FlutterGlPlugin _gl;
  bool _isLoaded = false;
  double _cubeRotY = 0.0;
  double _cubePosX = 0.0;
  double _cubePosY = 0.0;
  double _cubePosZ = 0.0;

  @override
  void initState() {
    super.initState();
    _initGL();
  }

  Future<void> _initGL() async {
    _gl = FlutterGlPlugin();
    await _gl.initialize();
    
    // تنظیمات اولیه صحنه سه بعدی
    _gl.gl.clearColor(0.1, 0.1, 0.2, 1.0);
    _gl.gl.enable(WebGL.DEPTH_TEST);
    _gl.gl.enable(WebGL.CULL_FACE);

    setState(() {
      _isLoaded = true;
    });

    // شروع حلقه رندر
    _renderLoop();
  }

  void _renderLoop() {
    if (!mounted) return;
    
    // آپدیت چرخش مکعب
    setState(() {
      _cubeRotY += 0.02;
    });

    _gl.gl.clear(WebGL.COLOR_BUFFER_BIT | WebGL.DEPTH_BUFFER_BIT);
    
    // اینجا می‌توانید کدهای رندر با شیدرها و متریال‌ها را اضافه کنید
    // فعلا برای تست یک مکعب ساده رندر می‌کنیم

    _gl.update();
    Future.delayed(const Duration(milliseconds: 16), _renderLoop);
  }

  @override
  void dispose() {
    _gl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // نمایش صحنه سه بعدی
          Positioned.fill(
            child: _isLoaded
                ? FlutterGlView(
                    gl: _gl,
                    width: MediaQuery.of(context).size.width.toInt(),
                    height: MediaQuery.of(context).size.height.toInt(),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          
          // دکمه‌های کنترل
          Positioned(
            top: 40, left: 10, right: 10,
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildButton('↔️ جابجایی', () => setState(() => _cubePosX += 0.5)),
                _buildButton('🔄 چرخش', () => setState(() => _cubeRotY += 0.5)),
                _buildButton('📐 مقیاس', () => setState(() {})),
                _buildButton('🧊 مکعب', () => setState(() => _cubePosY += 0.5)),
              ],
            ),
          ),

          // پنل تنظیمات
          Positioned(
            bottom: 20, left: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xEE141428),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تنظیمات مکعب', style: TextStyle(color: Colors.lightBlue)),
                  Row(
                    children: [
                      _buildNumberField('X', _cubePosX, (v) => setState(() => _cubePosX = v)),
                      _buildNumberField('Y', _cubePosY, (v) => setState(() => _cubePosY = v)),
                      _buildNumberField('Z', _cubePosZ, (v) => setState(() => _cubePosZ = v)),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.black,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNumberField(String label, double value, Function(double) onChanged) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextFormField(
          initialValue: value.toStringAsFixed(1),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFF2A2A4A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          ),
          onChanged: (val) {
            if (double.tryParse(val) != null) onChanged(double.parse(val));
          },
        ),
      ),
    );
  }
}