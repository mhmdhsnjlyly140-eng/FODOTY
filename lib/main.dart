import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_controls/three_js_controls.dart';
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
  late three.ThreeJS threeJs;
  late three.Scene scene;
  late three.PerspectiveCamera camera;
  late OrbitControls orbitControls;
  
  final List<three.Object3D> _objects = [];
  three.Object3D? _selectedObject;
  String _currentMode = 'translate';

  @override
  void initState() {
    super.initState();
    threeJs = three.ThreeJS(
      onSetupComplete: () => setState(() {}),
      setup: setupScene,
    );
  }

  void setupScene() {
    scene = three.Scene();
    scene.background = three.Color(0x1a1a2e);

    camera = three.PerspectiveCamera(75, threeJs.width / threeJs.height, 0.1, 1000);
    camera.position.setValues(5.0, 5.0, 8.0);

    scene.add(three.AmbientLight(0xffffff, 0.6));
    final dirLight = three.DirectionalLight(0xffffff, 1);
    dirLight.position.setValues(5.0, 10.0, 7.0);
    scene.add(dirLight);

    final groundGeometry = three.PlaneGeometry(30, 30);
    final groundMaterial = three.MeshStandardMaterial({
      three.MaterialProperty.color: three.Color(0x2a2a4a),
    });
    final ground = three.Mesh(groundGeometry, groundMaterial);
    ground.rotation.x = -math.pi / 2;
    scene.add(ground);

    // اصلاح شد به globalKey
    orbitControls = OrbitControls(camera, threeJs.globalKey); 
    orbitControls.enableDamping = true;
    orbitControls.dampingFactor = 0.1;
    
    addCube();
  }

  void addCube() {
    final geometry = three.BoxGeometry(1, 1, 1);
    final material = three.MeshStandardMaterial({
      three.MaterialProperty.color: three.Color(0x4fc3f7),
    });
    final cube = three.Mesh(geometry, material);
    
    cube.position.setValues(
      (math.Random().nextDouble() - 0.5) * 4,
      3.0,
      (math.Random().nextDouble() - 0.5) * 4,
    );
    
    scene.add(cube);
    _objects.add(cube);
    setState(() {});
  }

  void onTapUp(three.Vector2 screenCoord) {
    final raycaster = three.Raycaster();
    raycaster.setFromCamera(screenCoord, camera);
    final intersects = raycaster.intersectObjects(_objects, true);
    
    setState(() {
      _selectedObject = intersects.isNotEmpty ? intersects[0].object : null;
    });
  }

  void changeMode(String mode) => setState(() => _currentMode = mode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // اصلاح شد به buildWidget
          Positioned.fill(
            child: threeJs.buildWidget(onTapUp: onTapUp),
          ),
          
          Positioned(
            top: 40, left: 10, right: 10,
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildButton('↔️ جابجایی', () => changeMode('translate'), isActive: _currentMode == 'translate'),
                _buildButton('🔄 چرخش', () => changeMode('rotate'), isActive: _currentMode == 'rotate'),
                _buildButton('📐 مقیاس', () => changeMode('scale'), isActive: _currentMode == 'scale'),
                _buildButton('🧊 مکعب', addCube),
              ],
            ),
          ),

          if (_selectedObject != null)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('تنظیمات شیء', style: TextStyle(color: Colors.lightBlue)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _selectedObject = null)),
                      ],
                    ),
                    Row(
                      children: [
                        _buildNumberField('X', _selectedObject!.position.x, (v) => setState(() => _selectedObject!.position.x = v)),
                        _buildNumberField('Y', _selectedObject!.position.y, (v) => setState(() => _selectedObject!.position.y = v)),
                        _buildNumberField('Z', _selectedObject!.position.z, (v) => setState(() => _selectedObject!.position.z = v)),
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

  Widget _buildButton(String text, VoidCallback onPressed, {bool isActive = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.orange : Colors.lightBlue,
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