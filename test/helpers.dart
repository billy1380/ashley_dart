import 'package:test/test.dart';

void assertEquals(dynamic matcher, dynamic actual) {
  expect(actual, matcher);
}

void assertNotEquals(dynamic matcher, dynamic actual) {
  assertFalse(actual == matcher);
}

void assertTrue(bool actual) {
  assertEquals(actual, true);
}

void assertFalse(bool actual) {
  assertEquals(actual, false);
}

void assertNotNull(dynamic actual) {
  assertFalse(actual == null);
}

void assertNull(dynamic actual) {
  assertTrue(actual == null);
}
