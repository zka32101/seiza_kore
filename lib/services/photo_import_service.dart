import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 望遠鏡等で撮影した写真を端末のギャラリーから選び、
/// アプリの永続ストレージにコピーして観測記録に添付するためのサービス。
class PhotoImportService {
  PhotoImportService._();
  static final PhotoImportService instance = PhotoImportService._();

  final ImagePicker _picker = ImagePicker();

  /// ギャラリーから複数枚選択し、アプリのドキュメントディレクトリ内
  /// `observation_photos/` にコピーしたローカルパスのリストを返す。
  /// 選択がキャンセルされた場合は空リストを返す。
  Future<List<String>> pickAndImportPhotos() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return [];

    final docsDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${docsDir.path}/observation_photos');
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final savedPaths = <String>[];
    for (final file in picked) {
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final fileName =
          'photo_${DateTime.now().microsecondsSinceEpoch}_${savedPaths.length}.$ext';
      final savedFile = await File(file.path).copy('${photosDir.path}/$fileName');
      savedPaths.add(savedFile.path);
    }
    return savedPaths;
  }

  /// 観測記録削除時に、紐づく写真ファイルも削除する。
  Future<void> deletePhotos(List<String> paths) async {
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
