import 'package:image_picker/image_picker.dart';
import '../models/document.dart';

abstract class DocumentRepository {
  Future<List<AppDocument>> getDocuments({String? category, String? status});
  Future<AppDocument> createDocument({
    required String title,
    required String category,
    String? description,
    String? status,
    XFile? file,
  });
  Future<AppDocument> updateDocument(int id, {
    String? title,
    String? category,
    String? description,
    String? status,
    XFile? file,
  });
  Future<void> deleteDocument(int id);
}
