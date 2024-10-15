import '../../data/models/cloze.dart';

abstract interface class IClozeService {
  bool get initialized;
  Cloze getRandomCloze();
  Future<void> addForReview(Cloze cloze);
}
