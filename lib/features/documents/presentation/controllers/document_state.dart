import '../../domain/models/document.dart';

abstract class DocumentState {}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<AppDocument> documents;
  DocumentLoaded({required this.documents});
}

class DocumentError extends DocumentState {
  final String message;
  DocumentError({required this.message});
}
