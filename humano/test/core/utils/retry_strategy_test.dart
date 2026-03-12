import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:humano/core/utils/retry_strategy.dart';

// Feature: user-database-system, Property 10: Retry on network failure
// For any write operation that fails due to network error, 
// the system should retry up to 3 times before reporting failure

void main() {
  group('RetryStrategy Property-Based Tests', () {
    late RetryStrategy retryStrategy;

    setUp(() {
      retryStrategy = RetryStrategy();
    });

    test('Property 10: Retries exactly 3 times on retriable error', () async {
      int attemptCount = 0;

      try {
        await retryStrategy.executeWithRetry(() async {
          attemptCount++;
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Service unavailable',
          );
        });
      } catch (e) {
        // Expected to fail after retries
      }

      expect(attemptCount, equals(3), reason: 'Should retry exactly 3 times');
    });

    test('Property 10: Does not retry on non-retriable error', () async {
      int attemptCount = 0;

      try {
        await retryStrategy.executeWithRetry(() async {
          attemptCount++;
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Permission denied',
          );
        });
      } catch (e) {
        // Expected to fail immediately
      }

      expect(attemptCount, equals(1), reason: 'Should not retry non-retriable errors');
    });

    test('Property 10: Succeeds on first attempt if no error', () async {
      int attemptCount = 0;

      final result = await retryStrategy.executeWithRetry(() async {
        attemptCount++;
        return 'success';
      });

      expect(result, equals('success'));
      expect(attemptCount, equals(1), reason: 'Should succeed on first attempt');
    });

    test('Property 10: Succeeds on retry after initial failures', () async {
      int attemptCount = 0;

      final result = await retryStrategy.executeWithRetry(() async {
        attemptCount++;
        if (attemptCount < 3) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Service unavailable',
          );
        }
        return 'success';
      });

      expect(result, equals('success'));
      expect(attemptCount, equals(3), reason: 'Should succeed on third attempt');
    });

    test('Property 10: Exponential backoff increases delay', () async {
      final delays = <Duration>[];
      DateTime? lastAttempt;

      try {
        await retryStrategy.executeWithRetryAndCallback(
          () async {
            if (lastAttempt != null) {
              delays.add(DateTime.now().difference(lastAttempt!));
            }
            lastAttempt = DateTime.now();

            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'unavailable',
              message: 'Service unavailable',
            );
          },
          onRetry: (attempt, error) {
            // Callback for retry
          },
        );
      } catch (e) {
        // Expected to fail
      }

      // Verify delays increase (with some tolerance for timing)
      expect(delays.length, equals(2), reason: 'Should have 2 delays between 3 attempts');
      if (delays.length >= 2) {
        expect(
          delays[1].inMilliseconds,
          greaterThan(delays[0].inMilliseconds),
          reason: 'Second delay should be longer than first',
        );
      }
    });

    test('Property 10: Retriable error codes are retried', () async {
      final retriableErrors = [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'aborted',
        'internal',
        'unknown',
      ];

      for (final errorCode in retriableErrors) {
        int attemptCount = 0;

        try {
          await retryStrategy.executeWithRetry(() async {
            attemptCount++;
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: errorCode,
              message: 'Error',
            );
          });
        } catch (e) {
          // Expected to fail
        }

        expect(
          attemptCount,
          equals(3),
          reason: 'Error code $errorCode should be retried 3 times',
        );
      }
    });

    test('Property 10: Non-retriable error codes fail immediately', () async {
      final nonRetriableErrors = [
        'permission-denied',
        'not-found',
        'already-exists',
        'invalid-argument',
        'unauthenticated',
      ];

      for (final errorCode in nonRetriableErrors) {
        int attemptCount = 0;

        try {
          await retryStrategy.executeWithRetry(() async {
            attemptCount++;
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: errorCode,
              message: 'Error',
            );
          });
        } catch (e) {
          // Expected to fail
        }

        expect(
          attemptCount,
          equals(1),
          reason: 'Error code $errorCode should not be retried',
        );
      }
    });
  });
}
