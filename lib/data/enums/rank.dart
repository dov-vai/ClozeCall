enum Rank {
  zero(days: 1),
  one(days: 3),
  two(days: 7),
  three(days: 14),
  four(days: 30),
  five(days: 60);

  const Rank({required this.days});

  final int days;

  Rank increment() {
    if (index < Rank.values.length - 1) {
      return Rank.values[index + 1];
    }
    return this;
  }

  Rank decrement() {
    if (index > 0) {
      return Rank.values[index - 1];
    }
    return this;
  }

  static Rank get(int index) {
    return Rank.values[index];
  }
}
