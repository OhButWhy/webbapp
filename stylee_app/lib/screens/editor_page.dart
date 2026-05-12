import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylee_app/screens/post_preview_page.dart';

class EditorPage extends StatefulWidget {
  final VoidCallback? onFinish;
  
  const EditorPage({super.key, this.onFinish});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  String? _activeTool;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() => _selectedImagePath = image.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return;
      print('❌ Ошибка picker: $e');
    } catch (e) {
      print('❌ Неожиданная ошибка: $e');
    }
  }

  void _toggleTool(String tool) {
    setState(() {
      _activeTool = _activeTool == tool ? null : tool;
    });
  }

  void _goToPreview() {
    if (_selectedImagePath == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostPreviewPage(
          imagePath: _selectedImagePath!,
          onFinish: widget.onFinish,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _selectedImagePath != null ? Icons.arrow_back : Icons.close,
            color: Colors.black87,
          ),
          onPressed: () => widget.onFinish?.call(),
        ),
        title: const Text(
          'Editor',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_selectedImagePath != null)
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFFE91E63), size: 28),
              onPressed: _goToPreview,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImagePath == null 
                ? _buildEmptyState()
                : _buildEditor(),
          ),

          if (_selectedImagePath != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildToolIcon(Icons.crop, 'Crop', 'crop'),
                  _buildToolIcon(Icons.filter, 'Filters', 'filters'),
                  _buildToolIcon(Icons.color_lens, 'Color', 'color'),
                  _buildToolIcon(Icons.auto_fix_high, 'AI', 'ai'),
                ],
              ),
            ),

            if (_activeTool != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildControls(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.pink.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 50,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Выберите фото',
            style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, color: Colors.white, size: 20),
            label: const Text('Галерея', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(_selectedImagePath!),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String label, String toolKey) {
    final isActive = _activeTool == toolKey;
    return GestureDetector(
      onTap: () => _toggleTool(toolKey),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE91E63) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? const Color(0xFFE91E63) : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    switch (_activeTool) {
      case 'color':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSlider('Brightness', 0.0, -1.0, 1.0),
            const SizedBox(height: 16),
            _buildSlider('Contrast', 1.0, 0.5, 2.0),
          ],
        );
      case 'filters':
        return const Center(child: Text('🎨 Фильтры (в разработке)', style: TextStyle(color: Colors.black54)));
      case 'crop':
        return const Center(child: Text('✂️ Обрезка (в разработке)', style: TextStyle(color: Colors.black54)));
      case 'ai':
        return const Center(child: Text('✨ AI (в разработке)', style: TextStyle(color: Colors.black54)));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSlider(String label, double value, double min, double max) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: const Color(0xFFE91E63),
            inactiveColor: Colors.pink.shade100,
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }
}