/*******************************************************************************
 * Copyright 2014 See AUTHORS file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

import '../helpers.dart';

const double deltaTime = 0.1;

class IntervalComponentSpy implements Component {
  int numUpdates = 0;
}

class IntervalIteratingSystemSpy extends IntervalIteratingSystem {
  late ComponentMapper<IntervalComponentSpy> _im;

  IntervalIteratingSystemSpy()
      : super(Family.all([IntervalComponentSpy]).get(), deltaTime * 2.0) {
    _im = ComponentMapper.getFor(IntervalComponentSpy);
  }

  @override
  void processEntity(Entity? entity) {
    _im[entity!]!.numUpdates++;
  }
}

void main() {
  group("Interval Iterating Test", () {
    IntervalIteratingTest tests = IntervalIteratingTest();

    test("interval system", tests.intervalSystem);
  });
}

class IntervalIteratingTest {
  void intervalSystem() {
    Engine engine = Engine();
    IntervalIteratingSystemSpy intervalSystemSpy = IntervalIteratingSystemSpy();
    List<Entity?> entities = engine[Family.all([IntervalComponentSpy]).get()];
    ComponentMapper<IntervalComponentSpy> im =
        ComponentMapper.getFor(IntervalComponentSpy);

    engine.addSystem(intervalSystemSpy);

    for (int i = 0; i < 10; ++i) {
      Entity entity = Entity();
      entity.add(IntervalComponentSpy());
      engine.addEntity(entity);
    }

    for (int i = 1; i <= 10; ++i) {
      engine.update(deltaTime);

      for (int j = 0; j < entities.length; ++j) {
        assertEquals(i ~/ 2, im[entities[j]!]!.numUpdates);
      }
    }
  }
}
