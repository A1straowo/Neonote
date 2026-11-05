import 'package:flutter_test/flutter_test.dart';
import 'package:neonote/deepseek/api_error_formatter.dart';

void main() {
  test('extracts DeepSeek JSON error message', () {
    expect(
      formatApiHttpError(
        statusCode: 401,
        body: '{"error":{"message":"Authentication Fails"}}',
      ),
      'HTTP 401: Authentication Fails',
    );
  });

  test('does not throw on an HTML gateway response', () {
    expect(
      formatApiHttpError(
        statusCode: 502,
        body: '<html><body>Bad Gateway</body></html>',
      ),
      'HTTP 502: <html><body>Bad Gateway</body></html>',
    );
  });

  test('handles an empty body', () {
    expect(formatApiHttpError(statusCode: 503, body: '  '), 'HTTP 503');
  });
}
