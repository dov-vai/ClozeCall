import 'cloze.dart';

abstract interface class IClozeService {
  bool get initialized;
  Cloze getRandomCloze();
}
