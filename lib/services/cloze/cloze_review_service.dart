import 'dart:math';

import 'package:cloze_call/data/models/cloze_review.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:flutter/cupertino.dart';

import 'cloze.dart';
import 'cloze_exceptions.dart';

class ClozeReviewService implements IClozeService {
  final List<ClozeReview> _clozes = List.empty(growable: true);
  final ClozeReviewRepository _clozeRepo;
  bool _initialized = false;
  final Random _random = Random();
  final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  @override
  bool get initialized => _initialized;

  int get count => _clozes.length;

  ClozeReviewService(this._clozeRepo);

  Future<void> initialize() async {
    var clozes = await _clozeRepo.entries();
    var now = DateTime.now().toUtc();

    // TODO: better review algorithm
    for (var cloze in clozes) {
      if (now.difference(cloze.timestamp).inDays >= 2) {
        _clozes.add(cloze);
      }
    }

    countNotifier.value = _clozes.length;

    _initialized = true;
  }

  @override
  Cloze getRandomCloze() {
    _isInitialized();

    if (_clozes.isEmpty) {
      throw ClozeServiceEmptyException();
    }

    var cloze = _clozes.removeAt(_random.nextInt(_clozes.length));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      countNotifier.value = _clozes.length;
    });

    _clozeRepo.update(cloze.copyWith(timestamp: DateTime.now().toUtc()));
    return Cloze.fromClozeReview(cloze);
  }

  void _isInitialized() {
    if (!initialized) {
      throw ClozeServiceException("Not initialized");
    }
  }
}
