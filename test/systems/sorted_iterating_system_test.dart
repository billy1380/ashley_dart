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

final ComponentMapper<OrderComponent> orderMapper =
    ComponentMapper.getFor(OrderComponent);

class ComponentB implements Component {}

class ComponentC implements Component {}

class SortedIteratingSystemMock extends SortedIteratingSystem {
  List<String> expectedNames = [];

  SortedIteratingSystemMock(Family family)
      : super(family, SortedIteratingSystemTest._compare);

  @override
  void update(double deltaTime) {
    super.update(deltaTime);
    assertTrue(expectedNames.isEmpty);
  }

  @override
  void processEntity(Entity? entity, double deltaTime) {
    OrderComponent component = orderMapper[entity!]!;
    assertNotNull(component);
    assertFalse(expectedNames.isEmpty);
    assertEquals(expectedNames.removeAt(0), component.name);
  }
}

class OrderComponent implements Component {
  String? name;
  int? zLayer;

  OrderComponent(String this.name, int this.zLayer);
}

class SpyComponent implements Component {
  int updates = 0;
}

class IndexComponent implements Component {
  int index = 0;
}

class IteratingComponentRemovalSystem extends SortedIteratingSystem {
  final ComponentMapper<SpyComponent> _sm;
  final ComponentMapper<IndexComponent> _im;

  IteratingComponentRemovalSystem()
      : _sm = ComponentMapper.getFor(SpyComponent),
        _im = ComponentMapper.getFor(IndexComponent),
        super(Family.all([SpyComponent, IndexComponent]).get(),
            SortedIteratingSystemTest._compare);

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

class IteratingRemovalSystem extends SortedIteratingSystem {
  Engine? _e;
  final ComponentMapper<SpyComponent> _sm;
  final ComponentMapper<IndexComponent> _im;

  IteratingRemovalSystem()
      : _sm = ComponentMapper.getFor(SpyComponent),
        _im = ComponentMapper.getFor(IndexComponent),
        super(Family.all([SpyComponent, IndexComponent]).get(),
            SortedIteratingSystemTest._compare);

  @override
  void addedToEngine(Engine? e) {
    super.addedToEngine(e);
    _e = e;
  }

  @override
  void processEntity(Entity? entity, double deltaTime) {
    int index = _im[entity!]!.index;
    if (index % 2 == 0) {
      _e!.removeEntity(entity);
    } else {
      _sm[entity]!.updates++;
    }
  }
}

void main() {
  group("Sorted Iterating System Test", () {
    SortedIteratingSystemTest tests = SortedIteratingSystemTest();

    test("should iterate entities with correct family",
        tests.shouldIterateEntitiesWithCorrectFamily);
    test("entity removal while iterating", tests.entityRemovalWhileIterating);
    test("component removal while iterating",
        tests.componentRemovalWhileIterating);
    test("entity order", tests.entityOrder);
  });
}

class SortedIteratingSystemTest {
  void shouldIterateEntitiesWithCorrectFamily() {
    final Engine engine = Engine();

    final Family family = Family.all([OrderComponent, ComponentB]).get();
    final SortedIteratingSystemMock system = SortedIteratingSystemMock(family);
    final Entity e = Entity();

    engine.addSystem(system);
    engine.addEntity(e);

    // When entity has OrderComponent
    e.add(OrderComponent("A", 0));
    engine.update(deltaTime);

    // When entity has OrderComponent and ComponentB
    e.add(ComponentB());
    system.expectedNames.add("A");
    engine.update(deltaTime);

    // When entity has OrderComponent, ComponentB and ComponentC
    e.add(ComponentC());
    system.expectedNames.add("A");
    engine.update(deltaTime);

    // When entity has ComponentB and ComponentC
    e.remove(OrderComponent);
    e.add(ComponentC());
    engine.update(deltaTime);
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
      e.add(OrderComponent("$i", i));

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
      e.add(OrderComponent("$i", i));

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

  static Entity _createOrderEntity(String name, int zLayer) {
    Entity entity = Entity();
    entity.add(OrderComponent(name, zLayer));
    return entity;
  }

  void entityOrder() {
    Engine engine = Engine();

    final Family family = Family.all([OrderComponent]).get();
    final SortedIteratingSystemMock system = SortedIteratingSystemMock(family);
    engine.addSystem(system);

    Entity a = _createOrderEntity("A", 0);
    Entity b = _createOrderEntity("B", 1);
    Entity c = _createOrderEntity("C", 3);
    Entity d = _createOrderEntity("D", 2);

    engine.addEntity(a);
    engine.addEntity(b);
    engine.addEntity(c);
    system.expectedNames.add("A");
    system.expectedNames.add("B");
    system.expectedNames.add("C");
    engine.update(0);

    engine.addEntity(d);
    system.expectedNames.add("A");
    system.expectedNames.add("B");
    system.expectedNames.add("D");
    system.expectedNames.add("C");
    engine.update(0);

    orderMapper[a]!.zLayer = 3;
    orderMapper[b]!.zLayer = 2;
    orderMapper[c]!.zLayer = 1;
    orderMapper[d]!.zLayer = 0;
    system.forceSort();
    system.expectedNames.add("D");
    system.expectedNames.add("C");
    system.expectedNames.add("B");
    system.expectedNames.add("A");
    engine.update(0);
  }

  static int _compare(Entity? a, Entity? b) {
    OrderComponent ac = orderMapper[a!]!;
    OrderComponent bc = orderMapper[b!]!;
    return ac.zLayer! > bc.zLayer!
        ? 1
        : (ac.zLayer == bc.zLayer)
            ? 0
            : -1;
  }
}
