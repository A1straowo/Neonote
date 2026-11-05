import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/store/mutation_queue.dart';

void main() {
  test('serializes read-modify-write operations', () async {
    final queue = MutationQueue();
    final events = <String>[];

    Future<void> mutate(String name, int delayMs) {
      return queue.run(() async {
        events.add('$name:start');
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        events.add('$name:end');
      });
    }

    await Future.wait([mutate('a', 20), mutate('b', 0), mutate('c', 0)]);

    expect(events, [
      'a:start',
      'a:end',
      'b:start',
      'b:end',
      'c:start',
      'c:end',
    ]);
  });

  test('a failed mutation does not poison the queue', () async {
    final queue = MutationQueue();
    await expectLater(
      queue.run<void>(() async => throw StateError('boom')),
      throwsStateError,
    );
    expect(await queue.run<int>(() async => 42), 42);
  });
}
