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

const double deltaTime = 0.16;

class ComponentA implements Component {}

class ComponentB implements Component {}

class ComponentC implements Component {}

class IteratingSystemMock extends IteratingSystem {
  int numUpdates = 0;

  IteratingSystemMock(super.family);

  @override
  void processEntity(Entity? entity, double deltaTime) {
    ++numUpdates;
  }
}

class SpyComponent implements Component {
  int updates = 0;
}

class IndexComponent implements Component {
  int index = 0;
}

class IteratingComponentRemovalSystem extends IteratingSystem {
  late ComponentMapper<SpyComponent> _sm;
  late ComponentMapper<IndexComponent> _im;

  IteratingComponentRemovalSystem()
      : super(Family.all([SpyComponent, IndexComponent]).get()) {
    _sm = ComponentMapper.getFor(SpyComponent);
    _im = ComponentMapper.getFor(IndexComponent);
  }

  @override
  void processEntity(Entity? entity, double deltaTime) {
    int index = _im[entity!]!.index;
    if (index % 2 == 0) {
      entity.remove(SpyComponent);
      entity.remove(IndexComponent);
    } else {
      _sm[entity]!.updates++;
    }
  }
}

class IteratingRemovalSystem extends IteratingSystem {
  final ComponentMapper<SpyComponent> _sm;
  final ComponentMapper<IndexComponent> _im;

  IteratingRemovalSystem()
      : _sm = ComponentMapper.getFor(SpyComponent),
        _im = ComponentMapper.getFor(IndexComponent),
        super(Family.all([SpyComponent, IndexComponent]).get());

  @override
  void processEntity(Entity? entity, double deltaTime) {
    int index = _im[entity!]!.index;
    if (index % 2 == 0) {
      engine!.removeEntity(entity);
    } else {
      _sm[entity]!.updates++;
    }
  }
}

void main() {
  group("Iterating System Test", () {
    IteratingSystemTest tests = IteratingSystemTest();

    test("should iterate entities with correct family",
        tests.shouldIterateEntitiesWithCorrectFamily);
    test("entity removal while iterating", tests.entityRemovalWhileIterating);
    test("entity removal while iterating", tests.entityRemovalWhileIterating);
  });
}

class IteratingSystemTest {
  void shouldIterateEntitiesWithCorrectFamily() {
    final Engine engine = Engine();

    final Family family = Family.all([ComponentA, ComponentB]).get();
    final IteratingSystemMock system = IteratingSystemMock(family);
    final Entity e = Entity();

    engine.addSystem(system);
    engine.addEntity(e);

    // When entity has ComponentA
    e.add(ComponentA());
    engine.update(deltaTime);

    assertEquals(0, system.numUpdates);

    // When entity has ComponentA and ComponentB
    system.numUpdates = 0;
    e.add(ComponentB());
    engine.update(deltaTime);

    assertEquals(1, system.numUpdates);

    // When entity has ComponentA, ComponentB and ComponentC
    system.numUpdates = 0;
    e.add(ComponentC());
    engine.update(deltaTime);

    assertEquals(1, system.numUpdates);

    // When entity has ComponentB and ComponentC
    system.numUpdates = 0;
    e.remove(ComponentA);
    e.add(ComponentC());
    engine.update(deltaTime);

    assertEquals(0, system.numUpdates);
  }

  void entityRemovalWhileIterating() {
    Engine engine = Engine();
    List<Entity?> entities =
        engine[Family.all([SpyComponent, IndexComponent]).get()];
    ComponentMapper<SpyComponent> sm = ComponentMapper.getFor(SpyComponent);

    engine.addSystem(IteratingRemovalSystem());

    final int numEntities = 10;

    for (int i = 0; i < numEntities; ++i) {
      Entity e = Entity();
      e.add(SpyComponent());

      IndexComponent input = IndexComponent();
      input.index = i + 1;

      e.add(input);

      engine.addEntity(e);
    }

    engine.update(deltaTime);

    assertEquals(numEntities ~/ 2, entities.length);

    for (int i = 0; i < entities.length; ++i) {
      Entity e = entities[i]!;

      assertEquals(1, sm[e]!.updates);
    }
  }

  void componentRemovalWhileIterating() {
    Engine engine = Engine();
    List<Entity?> entities =
        engine[Family.all([SpyComponent, IndexComponent]).get()];
    ComponentMapper<SpyComponent> sm = ComponentMapper.getFor(SpyComponent);

    engine.addSystem(IteratingComponentRemovalSystem());

    final int numEntities = 10;

    for (int i = 0; i < numEntities; ++i) {
      Entity e = Entity();
      e.add(SpyComponent());

      IndexComponent input = IndexComponent();
      input.index = i + 1;

      e.add(input);

      engine.addEntity(e);
    }

    engine.update(deltaTime);

    assertEquals(numEntities ~/ 2, entities.length);

    for (int i = 0; i < entities.length; ++i) {
      Entity e = entities[i]!;

      assertEquals(1, sm[e]!.updates);
    }
  }
}
