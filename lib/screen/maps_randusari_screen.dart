import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class MapsRandusariScreen extends StatefulWidget {
  const MapsRandusariScreen({super.key});

  @override
  State<MapsRandusariScreen> createState() => _MapsRandusariScreenState();
}

class _MapsRandusariScreenState extends State<MapsRandusariScreen> {
  ui.Image? _Image;
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapImage();
  }

  Future<void> _loadMapImage() async {
    try {
      final ByteData data = await rootBundle.load(
        'images/petarandusari1 (1).png',
      );
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Image image = await decodeImageFromList(bytes);
      setState(() {
        _Image = image;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback jika gambar tidak ditemukan
      print('Error loading image: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Kelurahan Randusari'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _scale = (_scale * 1.2).clamp(0.5, 5.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _scale = (_scale / 1.2).clamp(0.5, 5.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offset = Offset.zero;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onScaleStart: (details) {
                _previousScale = _scale;
                _previousOffset = _offset;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _scale = _previousScale * details.scale;
                  _scale = _scale.clamp(0.5, 5.0);

                  _offset = Offset(
                    _previousOffset.dx + details.focalPointDelta.dx,
                    _previousOffset.dy + details.focalPointDelta.dy,
                  );
                });
              },
              child: Stack(
                children: [
                  // Latar belakang grid
                  CustomPaint(painter: GridPainter(), size: Size.infinite),

                  // Peta dengan transformasi
                  Transform.translate(
                    offset: _offset,
                    child: Transform.scale(
                      scale: _scale,
                      child: Center(
                        child: CustomPaint(
                          painter: Painter(_Image!),
                          size: Size(
                            _Image!.width.toDouble(),
                            _Image!.height.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildLegend(),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Keterangan Wilayah',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('KEL. KARANGKETUG', Colors.blue),
              _buildLegendItem('KEL. RANDUSARI', Colors.deepOrange[400]!),
              _buildLegendItem('KEL. PETAHUNAN', Colors.greenAccent),
              _buildLegendItem('KEL. KRAPYAKREJO', Colors.greenAccent[700]!),
              _buildLegendItem('RW 01', Colors.redAccent),
              _buildLegendItem(
                'RW 02',
                const Color.fromARGB(255, 233, 124, 204),
              ),
              _buildLegendItem('RW 03', Colors.red[700]!),
              _buildLegendItem('RW 04', Colors.red[400]!),
              _buildLegendItem(
                'RW 05',
                const Color.fromARGB(255, 203, 134, 215),
              ),
              _buildLegendItem('RW 06', Colors.orange[400]!),
              _buildLegendItem('RW 07', const Color.fromARGB(220, 224, 26, 92)),
              _buildLegendItem('RW 08', Colors.orangeAccent[700]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class Painter extends CustomPainter {
  final ui.Image image;

  Painter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..filterQuality = FilterQuality.high
      ..isAntiAlias = true;

    // Gambar peta
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Tambahkan border
    final borderPaint = Paint()
      ..color = Colors.blue[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    // Grid vertikal
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Grid horizontal
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
