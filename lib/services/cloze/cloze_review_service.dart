import 'dart:math';

import 'package:cloze_call/data/models/cloze_review.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/services/cloze/cloze_service.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';

import 'cloze.dart';

class ClozeReviewService implements IClozeService {
  final List<ClozeReview> _clozes = List.empty(growable: true);
  final ClozeReviewRepository _clozeRepo;
  bool _initialized = false;
  final Random _random = Random();

  @override
  bool get initialized => _initialized;

  int get count => _clozes.length;

  ClozeReviewService(this._clozeRepo);

  Future<void> initialize() async {
    var clozes = await _clozeRepo.entries();
    var now = DateTime.now().toUtc();

    // TODO: better review algorithm
    for (var cloze in clozes) {
      if (now.difference(cloze.timestamp).inMinutes >= 2) {
        _clozes.add(cloze);
      }
    }

    _initialized = true;
  }

  @override
  Cloze getRandomCloze() {
    _isInitialized();

    if (_clozes.isEmpty) {
      throw ClozeServiceException("No clozes to return!");
    }

    var cloze = _clozes.removeAt(_random.nextInt(_clozes.length));
    _clozeRepo.update(cloze.copyWith(timestamp: DateTime.now().toUtc()));
    return Cloze.fromClozeReview(cloze);
  }

  void _isInitialized() {
    if (!initialized) {
      throw ClozeServiceException("Not initialized");
    }
  }
}
