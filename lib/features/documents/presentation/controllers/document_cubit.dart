import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/document_repository.dart';
import 'document_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  final DocumentRepository _repository;

  DocumentCubit(this._repository) : super(DocumentInitial());

  DateTime? _lastFetch;
  static const _cacheTtl = Duration(seconds: 60);
  bool get _isFresh =>
      _lastFetch != null && DateTime.now().difference(_lastFetch!) < _cacheTtl;

  Future<void> fetchDocuments({String? category, String? status, bool forceRefresh = false}) async {
    if (!forceRefresh && _isFresh && state is DocumentLoaded) return;

    emit(DocumentLoading());
    try {
      final documents = await _repository.getDocuments(category: category, status: status);
      _lastFetch = DateTime.now();
      emit(DocumentLoaded(documents: documents));
    } catch (e) {
      emit(DocumentError(message: e.toString()));
    }
  }

  Future<void> createDocument({
    required String title,
    required String category,
    String? description,
    String? status,
    XFile? file,
  }) async {
    try {
      await _repository.createDocument(
        title: title,
        category: category,
        description: description,
        status: status,
        file: file,
      );
      _lastFetch = null;
      await fetchDocuments(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateDocument(int id, {
    String? title,
    String? category,
    String? description,
    String? status,
    XFile? file,
  }) async {
    try {
      await _repository.updateDocument(
        id,
        title: title,
        category: category,
        description: description,
        status: status,
        file: file,
      );
      _lastFetch = null;
      await fetchDocuments(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _repository.deleteDocument(id);
      _lastFetch = null;
      await fetchDocuments(forceRefresh: true);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
