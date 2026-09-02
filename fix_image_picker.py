import re

def fix_file(path):
    with open(path, 'r') as f:
        content = f.read()

    # The buggy implementation
    buggy = """  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImage = XFile(result.files.single.path!);
      });
    }
  }"""

    # The fixed implementation using ImagePicker
    fixed = """  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçilemedi: $e')),
      );
    }
  }"""

    content = content.replace(buggy, fixed)
    
    with open(path, 'w') as f:
        f.write(content)


fix_file('lib/features/maintenance/presentation/pages/create_maintenance_page.dart')
fix_file('lib/features/maintenance/presentation/pages/manager_create_maintenance_page.dart')

