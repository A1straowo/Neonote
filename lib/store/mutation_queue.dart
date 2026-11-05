import 'dart:async';

/// Serializes asynchronous read-modify-write operations.
///
/// Jobs live in an explicit FIFO. The queue does not retain a `Future` from a
/// previous operation, which avoids zone/fake-async leaks in widget tests.
class MutationQueue {
  final List<Future<void> Function()> _pending = <Future<void> Function()>[];
  bool _running = false;

  Future<T> run<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _pending.add(() async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    _drain();
    return completer.future;
  }

  void _drain() {
    if (_running) return;
    _running = true;
    scheduleMicrotask(_process);
  }

  Future<void> _process() async {
    try {
      while (_pending.isNotEmpty) {
        final job = _pending.removeAt(0);
        await job();
      }
    } finally {
      _running = false;
      if (_pending.isNotEmpty) _drain();
    }
  }
}
