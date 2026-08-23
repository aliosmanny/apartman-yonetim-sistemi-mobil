import 'package:image_picker/image_picker.dart';
import '../../domain/models/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_data_source.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remoteDataSource;

  DocumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AppDocument>> getDocuments({String? category, String? status}) async {
    final dtos = await _remoteDataSource.getDocuments(category: category, status: status);
    return dtos.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<AppDocument> createDocument({
    required String title,
    required String category,
    String? description,
    String? status,
    XFile? file,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'category': category,
    };
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;

    final dto = await _remoteDataSource.createDocument(data, file: file);
    return dto.toModel();
  }

  @override
  Future<AppDocument> updateDocument(int id, {
    String? title,
    String? category,
    String? description,
    String? status,
    XFile? file,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (category != null) data['category'] = category;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;

    final dto = await _remoteDataSource.updateDocument(id, data, file: file);
    return dto.toModel();
  }

  @override
  Future<void> deleteDocument(int id) async {
    await _remoteDataSource.deleteDocument(id);
  }
}
