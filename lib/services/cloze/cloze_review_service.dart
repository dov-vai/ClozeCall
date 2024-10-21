import 'dart:math';

import 'package:cloze_call/data/models/cloze.dart';
import 'package:cloze_call/data/repositories/cloze_review_repository.dart';
import 'package:cloze_call/services/cloze/i_cloze_service.dart';
import 'package:flutter/cupertino.dart';

import 'cloze_exceptions.dart';

class ClozeReviewService implements IClozeService {
  final List<Cloze> _clozes = List.empty(growable: true);
  final ClozeReviewRepository _clozeRepo;
  bool _initialized = false;
  final Random _random = Random();
  final ValueNotifier<int> countNotifier = ValueNotifier<int>(0);

  @override
  bool get initialized => _initialized;

  int get count => _clozes.length;

  ClozeReviewService(this._clozeRepo);

  Future<void> initialize() async {
    if (initialized) {
      return;
    }

    var clozes = await _clozeRepo.entries();
    var now = DateTime.now().toUtc();

    for (var cloze in clozes) {
      if (now.difference(cloze.timestamp).inDays >= cloze.rank.days) {
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

    return cloze;
  }

  // should have it's rank increased/decreased depending whether it was answered correctly or not
  @override
  Future<void> addForReview(Cloze cloze) async {
    await _clozeRepo.update(cloze.copyWith(timestamp: DateTime.now().toUtc()));
  }

  void _isInitialized() {
    if (!initialized) {
      throw ClozeServiceException("Not initialized");
    }
  }
}
