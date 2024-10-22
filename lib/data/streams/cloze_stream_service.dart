import 'dart:async';

import 'package:cloze_call/data/repositories/cloze_review_repository.dart';

import '../models/cloze.dart';

// FIXME: needs a better name, gets confusing with the other 2 cloze services
class ClozeStreamService {
  final ClozeReviewRepository _repository;

  final _countController = StreamController<int>.broadcast();
  Stream<int> get count => _countController.stream;

  ClozeStreamService(this._repository) {
    _countController.onListen = _updateCount;
  }

  Future<List<Cloze>> getClozes() async {
    return await _repository.entries();
  }

  Future<void> addCloze(Cloze cloze) async {
    await _repository.insert(cloze);
    _updateCount();
  }

  Future<void> updateCloze(Cloze cloze) async {
    await _repository.update(cloze);
  }

  Future<void> _updateCount() async {
    _countController.add(await _repository.count());
  }

  void dispose() {
    _countController.close();
  }
}
