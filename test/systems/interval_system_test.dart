/// *****************************************************************************
/// Copyright 2014 See AUTHORS file.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///****************************************************************************
library;

import '../helpers.dart';
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

const double deltaTime = 0.1;

class IntervalSystemSpy extends IntervalSystem {
  int numUpdates = 0;

  IntervalSystemSpy() : super(deltaTime * 2.0);

  @override
  void updateInterval() {
    ++numUpdates;
  }
}

void main() {
  group("Interval Test", () {
    IntervalSystemTest tests = IntervalSystemTest();

    test("interval system", tests.intervalSystem);
    test("test get interval", tests.testGetInterval);
  });
}

class IntervalSystemTest {
  void intervalSystem() {
    Engine engine = Engine();
    IntervalSystemSpy intervalSystemSpy = IntervalSystemSpy();

    engine.addSystem(intervalSystemSpy);

    for (int i = 1; i <= 10; ++i) {
      engine.update(deltaTime);
      assertEquals(i ~/ 2, intervalSystemSpy.numUpdates);
    }
  }

  void testGetInterval() {
    IntervalSystemSpy intervalSystemSpy = IntervalSystemSpy();
    assertEquals(intervalSystemSpy.interval, deltaTime * 2.0);
  }
}
