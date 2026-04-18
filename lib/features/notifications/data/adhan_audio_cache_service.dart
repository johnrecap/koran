import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:quran_kareem/features/notifications/domain/adhan_muezzin.dart';

class AdhanAudioCacheService {
  AdhanAudioCacheService({
    Future<Directory> Function()? documentsDirectoryResolver,
    http.Client Function()? httpClientFactory,
    String Function(AdhanMuezzin)? urlResolver,
  })  : _documentsDirectoryResolver = documentsDirectoryResolver,
        _httpClientFactory = httpClientFactory,
        _urlResolver = urlResolver;

  final Future<Directory> Function()? _documentsDirectoryResolver;
  final http.Client Function()? _httpClientFactory;
  final String Function(AdhanMuezzin)? _urlResolver;

  Future<File> getOrDownload(AdhanMuezzin muezzin) async {
    final cached = await getCachedFile(muezzin);
    if (cached != null) {
      return cached;
    }
    return download(muezzin);
  }

  Future<File?> getCachedFile(AdhanMuezzin muezzin) async {
    final file = File(await _filePathFor(muezzin));
    if (await _isValidFile(file)) {
      return file;
    }
    if (await file.exists()) {
      await file.delete();
    }
    return null;
  }

  Future<String?> cachedFilePathFor(AdhanMuezzin muezzin) async {
    return (await getCachedFile(muezzin))?.path;
  }

  Future<File> download(AdhanMuezzin muezzin) async {
    final finalFile = File(await _filePathFor(muezzin));
    final partialFile = File('${finalFile.path}.part');
    final url = _urlResolver?.call(muezzin) ?? muezzin.cdnUrl;

    if (await partialFile.exists()) {
      await partialFile.delete();
    }

    await finalFile.parent.create(recursive: true);

    final client = _httpClientFactory?.call() ?? http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Unexpected status code ${response.statusCode}.',
          uri: Uri.parse(url),
        );
      }

      final sink = partialFile.openWrite();
      try {
        await response.stream.pipe(sink);
      } finally {
        await sink.close();
      }

      if (!await _isValidFile(partialFile)) {
        throw HttpException(
          'Downloaded adhan file is empty.',
          uri: Uri.parse(url),
        );
      }

      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await partialFile.rename(finalFile.path);
      return finalFile;
    } catch (_) {
      if (await partialFile.exists()) {
        await partialFile.delete();
      }
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<void> deleteCached(AdhanMuezzin muezzin) async {
    final file = File(await _filePathFor(muezzin));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> clearAll() async {
    final directory = await _cacheDirectory();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<Directory> _cacheDirectory() async {
    final documentsDirectory = await (_documentsDirectoryResolver?.call() ??
        getApplicationDocumentsDirectory());
    return Directory(path.join(documentsDirectory.path, 'adhan'));
  }

  Future<String> _filePathFor(AdhanMuezzin muezzin) async {
    final directory = await _cacheDirectory();
    return path.join(directory.path, muezzin.cacheFileName);
  }

  Future<bool> _isValidFile(File file) async {
    if (!await file.exists()) {
      return false;
    }
    return await file.length() > 0;
  }
}
