import 'dart:collection';

class UnmodifiablList<T> extends ListBase<T> {
  final List<T> original;

  UnmodifiablList(this.original);

  @override
  int get length => original.length;

  @override
  void set length(int value) => throw Exception("Unmodidifiable!");

  @override
  T operator [](int index) {
    return original[index];
  }

  @override
  void operator []=(int index, T value) {
    throw Exception("Unmodidifiable!");
  }

  @override
  void add(T element) {
    throw Exception("Unmodidifiable!");
  }

  @override
  void addAll(Iterable<T> iterable) {
    throw Exception("Unmodidifiable!");
  }

  @override
  bool remove(Object element) {
    throw Exception("Unmodidifiable!");
  }

  @override
  T removeAt(int index) {
    throw Exception("Unmodidifiable!");
  }

  @override
  void clear() {
    throw Exception("Unmodidifiable!");
  }

  @override
  void insert(int index, T element) {
    throw Exception("Unmodidifiable!");
  }

  @override
  void insertAll(int index, Iterable<T> iterable) {
    throw Exception("Unmodidifiable!");
  }

  @override
  void replaceRange(int start, int end, Iterable<T> newContents) {
    throw Exception("Unmodidifiable!");
  }
}

List<T> unmodifiable<T>(List<T> list) {
  return UnmodifiablList(list);
}
