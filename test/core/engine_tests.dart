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

import '../helpers.dart';
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

const double deltaTime = 0.16;

class ComponentA implements Component {}

class ComponentB implements Component {}

class ComponentC implements Component {}

class ComponentD implements Component {}

class EntityListenerMock implements EntityListener {
  int addedCount = 0;
  int removedCount = 0;

  @override
  void entityAdded(Entity? entity) {
    ++addedCount;
    assertNotNull(entity);
  }

  @override
  void entityRemoved(Entity? entity) {
    ++removedCount;
    assertNotNull(entity);
  }
}

class AddComponentBEntityListenerMock extends EntityListenerMock {
  @override
  void entityAdded(Entity? entity) {
    super.entityAdded(entity);

    entity!.add(ComponentB());
  }
}

class EntitySystemMock extends EntitySystem {
  int updateCalls = 0;
  int addedCalls = 0;
  int removedCalls = 0;

  /* private*/ List<int>? updates;

  EntitySystemMock([this.updates]);

  @override
  void update(double deltaTime) {
    ++updateCalls;

    if (updates != null) {
      updates!.add(priority);
    }
  }

  @override
  void addedToEngine(Engine? engine) {
    ++addedCalls;

    assertNotNull(engine);
  }

  @override
  void removedFromEngine(Engine? engine) {
    ++removedCalls;

    assertNotNull(engine);
  }
}

class EntitySystemMockA extends EntitySystemMock {
  EntitySystemMockA([List<int>? updates]) : super(updates);
}

class EntitySystemMockB extends EntitySystemMock {
  EntitySystemMockB([List<int>? updates]) : super(updates);
}

class CounterComponent implements Component {
  int counter = 0;
}

class CounterSystem extends EntitySystem {
  /* private*/ late List<Entity?> entities;

  @override
  void addedToEngine(Engine? engine) {
    entities = engine![Family.all([CounterComponent]).get()];
  }

  @override
  void update(double deltaTime) {
    for (int i = 0; i < entities.length; ++i) {
      if (i % 2 == 0) {
        entities[i]!
            .getComponent<CounterComponent>(CounterComponent)!
            .counter++;
      } else {
        engine!.removeEntity(entities[i]);
      }
    }
  }
}

class ComponentAddSystem extends IteratingSystem {
  ComponentAddedListener _listener;

  ComponentAddSystem(this._listener) : super(Family.all([]).get());

  @override
  void processEntity(Entity? entity, double deltaTime) {
    assertNull(entity!.getComponent(ComponentA));
    entity.add(ComponentA());
    assertNotNull(entity.getComponent(ComponentA));
    _listener.checkEntityListenerUpdate();
  }
}

class ComponentRemoveSystem extends IteratingSystem {
  ComponentRemovedListener _listener;

  ComponentRemoveSystem(this._listener) : super(Family.all([]).get());

  @override
  void processEntity(Entity? entity, double deltaTime) {
    assertNotNull(entity!.getComponent(ComponentA));
    entity.remove(ComponentA);
    assertNull(entity.getComponent(ComponentA));
    _listener.checkEntityListenerUpdate();
  }
}

class ComponentAddedListener implements EntityListener {
  int addedCalls = 0;
  int numEntities = 0;

  ComponentAddedListener(this.numEntities);

  @override
  void entityAdded(Entity? entity) {
    addedCalls++;
  }

  @override
  void entityRemoved(Entity? entity) {}

  void checkEntityListenerNonUpdate() {
    assertEquals(numEntities, addedCalls);
    addedCalls = 0;
  }

  void checkEntityListenerUpdate() {
    assertEquals(0, addedCalls);
  }
}

class ComponentRemovedListener implements EntityListener {
  int removedCalls = 0;
  int numEntities = 0;

  ComponentRemovedListener(this.numEntities);

  @override
  void entityAdded(Entity? entity) {}

  @override
  void entityRemoved(Entity? entity) {
    removedCalls++;
  }

  void checkEntityListenerNonUpdate() {
    assertEquals(numEntities, removedCalls);
    removedCalls = 0;
  }

  void checkEntityListenerUpdate() {
    assertEquals(0, removedCalls);
  }
}

class CascadeOperationsInListenersWhileUpdatingEntityListener1
    implements EntityListener {
  final Engine _engine;
  final List<Entity> _entities;
  final int _numEntities;
  const CascadeOperationsInListenersWhileUpdatingEntityListener1(
      this._engine, this._entities, this._numEntities);
  @override
  void entityRemoved(Entity? entity) {
    _engine.removeEntity(entity);
  }

  @override
  void entityAdded(Entity? entity) {
    if (_entities.length < _numEntities) {
      Entity e = Entity();
      _engine.addEntity(e);
    }
  }
}

class CascadeOperationsInListenersWhileUpdatingEntityListener2
    implements EntityListener {
  final List<Entity?> _entities;

  const CascadeOperationsInListenersWhileUpdatingEntityListener2(
      this._entities);
  @override
  void entityRemoved(Entity? entity) {
    _entities.remove(entity);
    if (_entities.isNotEmpty) {
      _entities.first!.remove(ComponentA);
    }
  }

  @override
  void entityAdded(Entity? entity) {
    _entities.add(entity);
    entity!.add(ComponentA());
  }
}

class CascadeOperationsInListenersWhileUpdatingEntitySystem1
    extends EntitySystem {
  @override
  void update(double deltaTime) {
    engine!.addEntity(Entity());
  }
}

class CascadeOperationsInListenersWhileUpdatingEntitySystem2
    extends EntitySystem {
  final List<Entity> _entities;

  CascadeOperationsInListenersWhileUpdatingEntitySystem2(this._entities);
  @override
  void update(double deltaTime) {
    engine!.removeEntity(_entities.first);
  }
}

class NestedUpdateExceptionEntitySystem extends EntitySystem {
  bool duringCallback = false;

  @override
  void update(double deltaTime) {
    if (!duringCallback) {
      duringCallback = true;
      engine!.update(deltaTime);
      duringCallback = false;
    }
  }
}

class SystemUpdateThrowsEntitySystem extends EntitySystem {
  @override
  void update(double deltaTime) {
    throw new Exception("throwing");
  }
}

void main() {
  group("Engine Tests", () {
    EngineTests tests = EngineTests();

    test("add and remove entity", tests.addAndRemoveEntity);
    test("add component inside listener", tests.addComponentInsideListener);
    test("add and remove system", tests.addAndRemoveSystem);
    test("get systems", tests.getSystems);
    test("add two systems of same class", tests.addTwoSystemsOfSameClass);
    test("system update", tests.systemUpdate);
    test("system update order", tests.systemUpdateOrder);
    test("entity system engine reference", tests.entitySystemEngineReference);
    test("ignore system", tests.ignoreSystem);
    test("entities for family", tests.entitiesForFamily);
    test("entity for family with removal", tests.entityForFamilyWithRemoval);
    test("entities for family after", tests.entitiesForFamilyAfter);
    test(
        "entities for family with removal", tests.entitiesForFamilyWithRemoval);
    test("entities for family with removal and filtering",
        tests.entitiesForFamilyWithRemovalAndFiltering);
    test("entity system removal while iterating",
        tests.entitySystemRemovalWhileIterating);
    test("entity add remove component while iterating",
        tests.entityAddRemoveComponentWhileIterating);
    test("cascade operations in listeners while updating",
        tests.cascadeOperationsInListenersWhileUpdating);
    test("family listener", tests.familyListener);
    test("create many entities no stack overflow",
        tests.createManyEntitiesNoStackOverflow);
    test("get entities", tests.getEntities);
    test("add entitytwice", tests.addEntityTwice);
    test("nested update exception", tests.nestedUpdateException);
    test("system update throws ", tests.systemUpdateThrows);
  });
}

class EngineTests {
  void addAndRemoveEntity() {
    Engine engine = Engine();

    EntityListenerMock listenerA = EntityListenerMock();
    EntityListenerMock listenerB = EntityListenerMock();

    engine.addEntityListener(null, 0, listenerA);
    engine.addEntityListener(null, 0, listenerB);

    Entity entity1 = Entity();
    engine.addEntity(entity1);

    assertEquals(1, listenerA.addedCount);
    assertEquals(1, listenerB.addedCount);

    engine.removeEntityListener(listenerB);

    Entity entity2 = Entity();
    engine.addEntity(entity2);

    assertEquals(2, listenerA.addedCount);
    assertEquals(1, listenerB.addedCount);

    engine.addEntityListener(null, 0, listenerB);

    engine.removeAllEntities();

    assertEquals(2, listenerA.removedCount);
    assertEquals(2, listenerB.removedCount);
  }

  void addComponentInsideListener() {
    Engine engine = Engine();

    EntityListenerMock listenerA = AddComponentBEntityListenerMock();
    EntityListenerMock listenerB = EntityListenerMock();

    engine.addEntityListener(Family.all([ComponentA]).get(), 0, listenerA);
    engine.addEntityListener(Family.all([ComponentB]).get(), 0, listenerB);

    Entity entity1 = Entity();
    entity1.add(ComponentA());
    engine.addEntity(entity1);

    assertEquals(1, listenerA.addedCount);
    assertNotNull(entity1.getComponent(ComponentB));
    assertEquals(1, listenerB.addedCount);
  }

  void addAndRemoveSystem() {
    Engine engine = Engine();
    EntitySystemMockA systemA = EntitySystemMockA();
    EntitySystemMockB systemB = EntitySystemMockB();

    assertNull(engine.getSystem(EntitySystemMockA));
    assertNull(engine.getSystem(EntitySystemMockB));

    engine.addSystem(systemA);
    engine.addSystem(systemB);

    assertNotNull(engine.getSystem(EntitySystemMockA));
    assertNotNull(engine.getSystem(EntitySystemMockB));
    assertEquals(1, systemA.addedCalls);
    assertEquals(1, systemB.addedCalls);

    engine.removeSystem(systemA);
    engine.removeSystem(systemB);

    assertNull(engine.getSystem(EntitySystemMockA));
    assertNull(engine.getSystem(EntitySystemMockB));
    assertEquals(1, systemA.removedCalls);
    assertEquals(1, systemB.removedCalls);

    engine.addSystem(systemA);
    engine.addSystem(systemB);
    engine.removeAllSystems();

    assertNull(engine.getSystem(EntitySystemMockA));
    assertNull(engine.getSystem(EntitySystemMockB));
    assertEquals(2, systemA.removedCalls);
    assertEquals(2, systemB.removedCalls);
  }

  void getSystems() {
    Engine engine = Engine();
    EntitySystemMockA systemA = EntitySystemMockA();
    EntitySystemMockB systemB = EntitySystemMockB();

    assertEquals(0, engine.systems!.length);

    engine.addSystem(systemA);
    engine.addSystem(systemB);

    assertEquals(2, engine.systems!.length);
  }

  void addTwoSystemsOfSameClass() {
    Engine engine = Engine();
    EntitySystemMockA system1 = EntitySystemMockA();
    EntitySystemMockA system2 = EntitySystemMockA();

    assertEquals(0, engine.systems!.length);

    engine.addSystem(system1);

    assertEquals(1, engine.systems!.length);
    assertEquals(system1, engine.getSystem(EntitySystemMockA));

    engine.addSystem(system2);

    assertEquals(1, engine.systems!.length);
    assertEquals(system2, engine.getSystem(EntitySystemMockA));
  }

  void systemUpdate() {
    Engine engine = Engine();
    EntitySystemMock systemA = EntitySystemMockA();
    EntitySystemMock systemB = EntitySystemMockB();

    engine.addSystem(systemA);
    engine.addSystem(systemB);

    int numUpdates = 10;

    for (int i = 0; i < numUpdates; ++i) {
      assertEquals(i, systemA.updateCalls);
      assertEquals(i, systemB.updateCalls);

      engine.update(deltaTime);

      assertEquals(i + 1, systemA.updateCalls);
      assertEquals(i + 1, systemB.updateCalls);
    }

    engine.removeSystem(systemB);

    for (int i = 0; i < numUpdates; ++i) {
      assertEquals(i + numUpdates, systemA.updateCalls);
      assertEquals(numUpdates, systemB.updateCalls);

      engine.update(deltaTime);

      assertEquals(i + 1 + numUpdates, systemA.updateCalls);
      assertEquals(numUpdates, systemB.updateCalls);
    }
  }

  void systemUpdateOrder() {
    List<int> updates = [];

    Engine engine = Engine();
    EntitySystemMock system1 = EntitySystemMockA(updates);
    EntitySystemMock system2 = EntitySystemMockB(updates);

    system1.priority = 2;
    system2.priority = 1;

    engine.addSystem(system1);
    engine.addSystem(system2);

    engine.update(deltaTime);

    int previous = INT_MIN;

    for (int value in updates) {
      assertTrue(value >= previous);
      previous = value;
    }
  }

  void entitySystemEngineReference() {
    Engine engine = Engine();
    EntitySystem system = EntitySystemMock();

    assertNull(system.engine);
    engine.addSystem(system);
    assertEquals(engine, system.engine);
    engine.removeSystem(system);
    assertNull(system.engine);
  }

  void ignoreSystem() {
    Engine engine = Engine();
    EntitySystemMock system = EntitySystemMock();

    engine.addSystem(system);

    int numUpdates = 10;

    for (int i = 0; i < numUpdates; ++i) {
      system.processing = (i % 2 == 0);
      engine.update(deltaTime);
      assertEquals(i ~/ 2 + 1, system.updateCalls);
    }
  }

  void entitiesForFamily() {
    Engine engine = Engine();

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = engine[family];

    assertEquals(0, familyEntities.length);

    Entity entity1 = Entity();
    Entity entity2 = Entity();
    Entity entity3 = Entity();
    Entity entity4 = Entity();

    entity1.add(ComponentA());
    entity1.add(ComponentB());

    entity2.add(ComponentA());
    entity2.add(ComponentC());

    entity3.add(ComponentA());
    entity3.add(ComponentB());
    entity3.add(ComponentC());

    entity4.add(ComponentA());
    entity4.add(ComponentB());
    entity4.add(ComponentC());

    engine.addEntity(entity1);
    engine.addEntity(entity2);
    engine.addEntity(entity3);
    engine.addEntity(entity4);

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));
  }

  void entityForFamilyWithRemoval() {
    // Test for issue #13
    Engine engine = Engine();

    Entity entity = Entity();
    entity.add(ComponentA());

    engine.addEntity(entity);

    List<Entity?> entities = engine[Family.all([ComponentA]).get()];

    assertEquals(1, entities.length);
    assertTrue(entities.contains(entity));

    engine.removeEntity(entity);

    assertEquals(0, entities.length);
    assertFalse(entities.contains(entity));
  }

  void entitiesForFamilyAfter() {
    Engine engine = Engine();

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = engine[family];

    assertEquals(0, familyEntities.length);

    Entity entity1 = Entity();
    Entity entity2 = Entity();
    Entity entity3 = Entity();
    Entity entity4 = Entity();

    engine.addEntity(entity1);
    engine.addEntity(entity2);
    engine.addEntity(entity3);
    engine.addEntity(entity4);

    entity1.add(ComponentA());
    entity1.add(ComponentB());

    entity2.add(ComponentA());
    entity2.add(ComponentC());

    entity3.add(ComponentA());
    entity3.add(ComponentB());
    entity3.add(ComponentC());

    entity4.add(ComponentA());
    entity4.add(ComponentB());
    entity4.add(ComponentC());

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));
  }

  void entitiesForFamilyWithRemoval() {
    Engine engine = Engine();

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = engine[family];

    Entity entity1 = Entity();
    Entity entity2 = Entity();
    Entity entity3 = Entity();
    Entity entity4 = Entity();

    engine.addEntity(entity1);
    engine.addEntity(entity2);
    engine.addEntity(entity3);
    engine.addEntity(entity4);

    entity1.add(ComponentA());
    entity1.add(ComponentB());

    entity2.add(ComponentA());
    entity2.add(ComponentC());

    entity3.add(ComponentA());
    entity3.add(ComponentB());
    entity3.add(ComponentC());

    entity4.add(ComponentA());
    entity4.add(ComponentB());
    entity4.add(ComponentC());

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));

    entity1.remove(ComponentA);
    engine.removeEntity(entity3);

    assertEquals(1, familyEntities.length);
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity1));
    assertFalse(familyEntities.contains(entity3));
    assertFalse(familyEntities.contains(entity2));
  }

  void entitiesForFamilyWithRemovalAndFiltering() {
    Engine engine = Engine();

    List<Entity?> entitiesWithComponentAOnly =
        engine[Family.all([ComponentA]).exclude([ComponentB]).get()];

    List<Entity?> entitiesWithComponentB =
        engine[Family.all([ComponentB]).get()];

    Entity entity1 = Entity();
    Entity entity2 = Entity();

    engine.addEntity(entity1);
    engine.addEntity(entity2);

    entity1.add(ComponentA());

    entity2.add(ComponentA());
    entity2.add(ComponentB());

    assertEquals(1, entitiesWithComponentAOnly.length);
    assertEquals(1, entitiesWithComponentB.length);

    entity2.remove(ComponentB);

    assertEquals(2, entitiesWithComponentAOnly.length);
    assertEquals(0, entitiesWithComponentB.length);
  }

  void entitySystemRemovalWhileIterating() {
    Engine engine = Engine();

    engine.addSystem(CounterSystem());

    for (int i = 0; i < 20; ++i) {
      Entity entity = Entity();
      entity.add(CounterComponent());
      engine.addEntity(entity);
    }

    List<Entity?> entities = engine[Family.all([CounterComponent]).get()];

    for (int i = 0; i < entities.length; ++i) {
      assertEquals(
          0,
          entities[i]!
              .getComponent<CounterComponent>(CounterComponent)!
              .counter);
    }

    engine.update(deltaTime);

    for (int i = 0; i < entities.length; ++i) {
      assertEquals(
          1,
          entities[i]!
              .getComponent<CounterComponent>(CounterComponent)!
              .counter);
    }
  }

  void entityAddRemoveComponentWhileIterating() {
    int numEntities = 20;
    Engine engine = Engine();
    ComponentAddedListener addedListener = ComponentAddedListener(numEntities);
    ComponentAddSystem addSystem = ComponentAddSystem(addedListener);

    ComponentRemovedListener removedListener =
        ComponentRemovedListener(numEntities);
    ComponentRemoveSystem removeSystem = ComponentRemoveSystem(removedListener);

    for (int i = 0; i < numEntities; ++i) {
      Entity entity = Entity();
      engine.addEntity(entity);
    }

    engine.addEntityListener(Family.all([ComponentA]).get(), 0, addedListener);
    engine.addEntityListener(
        Family.all([ComponentA]).get(), 0, removedListener);

    engine.addSystem(addSystem);
    engine.update(deltaTime);
    addedListener.checkEntityListenerNonUpdate();
    engine.removeSystem(addSystem);

    engine.addSystem(removeSystem);
    engine.update(deltaTime);
    removedListener.checkEntityListenerNonUpdate();
    engine.removeSystem(removeSystem);
  }

  void cascadeOperationsInListenersWhileUpdating() {
    // This test case mix both add/remove component and add/remove entities
    // in listeners.
    // Listeners trigger each other recursively to test cascade operations :

    // CREATION PHASE :
    // first listener will add a component which trigger the second,
    // second listener will create an entity which trigger the first one,
    // and so on.

    // DESTRUCTION PHASE :
    // first listener will remove component which trigger the second,
    // second listener will remove the entity which trigger the first one,
    // and so on.

    final int numEntities = 20;
    final Engine engine = Engine();
    ComponentAddedListener addedListener = ComponentAddedListener(numEntities);
    ComponentRemovedListener removedListener =
        ComponentRemovedListener(numEntities);

    final List<Entity> entities = [];

    engine.addEntityListener(
        Family.all([ComponentA]).get(),
        0,
        CascadeOperationsInListenersWhileUpdatingEntityListener1(
            engine, entities, numEntities));
    engine.addEntityListener(null, 0,
        CascadeOperationsInListenersWhileUpdatingEntityListener2(entities));

    engine.addEntityListener(Family.all([ComponentA]).get(), 0, addedListener);
    engine.addEntityListener(
        Family.all([ComponentA]).get(), 0, removedListener);

    // this system will just create an entity which will trigger
    // listeners cascade creations (up to 20)
    EntitySystem addSystem =
        CascadeOperationsInListenersWhileUpdatingEntitySystem1();

    engine.addSystem(addSystem);
    engine.update(deltaTime);
    engine.removeSystem(addSystem);
    addedListener.checkEntityListenerNonUpdate();
    removedListener.checkEntityListenerUpdate();

    // this system will just remove an entity which will trigger
    // listeners cascade deletion (up to 0)
    EntitySystem removeSystem =
        CascadeOperationsInListenersWhileUpdatingEntitySystem2(entities);

    engine.addSystem(removeSystem);
    engine.update(deltaTime);
    engine.removeSystem(removeSystem);
    addedListener.checkEntityListenerUpdate();
    removedListener.checkEntityListenerNonUpdate();
  }

  void familyListener() {
    Engine engine = Engine();

    EntityListenerMock listenerA = EntityListenerMock();
    EntityListenerMock listenerB = EntityListenerMock();

    Family familyA = Family.all([ComponentA]).get();
    Family familyB = Family.all([ComponentB]).get();

    engine.addEntityListener(familyA, 0, listenerA);
    engine.addEntityListener(familyB, 0, listenerB);

    Entity entity1 = Entity();
    engine.addEntity(entity1);

    assertEquals(0, listenerA.addedCount);
    assertEquals(0, listenerB.addedCount);

    Entity entity2 = Entity();
    engine.addEntity(entity2);

    assertEquals(0, listenerA.addedCount);
    assertEquals(0, listenerB.addedCount);

    entity1.add(ComponentA());

    assertEquals(1, listenerA.addedCount);
    assertEquals(0, listenerB.addedCount);

    entity2.add(ComponentB());

    assertEquals(1, listenerA.addedCount);
    assertEquals(1, listenerB.addedCount);

    entity1.remove(ComponentA);

    assertEquals(1, listenerA.removedCount);
    assertEquals(0, listenerB.removedCount);

    engine.removeEntity(entity2);

    assertEquals(1, listenerA.removedCount);
    assertEquals(1, listenerB.removedCount);

    engine.removeEntityListener(listenerB);

    engine.addEntity(entity2);

    assertEquals(1, listenerA.addedCount);
    assertEquals(1, listenerB.addedCount);

    entity1.add(ComponentB());
    entity1.add(ComponentA());

    assertEquals(2, listenerA.addedCount);
    assertEquals(1, listenerB.addedCount);

    engine.removeAllEntities();

    assertEquals(2, listenerA.removedCount);
    assertEquals(1, listenerB.removedCount);

    engine.addEntityListener(null, 0, listenerB);

    engine.addEntity(entity1);
    engine.addEntity(entity2);

    assertEquals(3, listenerA.addedCount);
    assertEquals(3, listenerB.addedCount);

    engine.removeAllEntities(familyA);

    assertEquals(3, listenerA.removedCount);
    assertEquals(2, listenerB.removedCount);

    engine.removeAllEntities(familyB);

    assertEquals(3, listenerA.removedCount);
    assertEquals(3, listenerB.removedCount);
  }

  void createManyEntitiesNoStackOverflow() {
    Engine engine = Engine();
    engine.addSystem(CounterSystem());

    for (int i = 0; 15000 > i; i++) {
      Entity e = Entity();
      e.add(CounterComponent());
      engine.addEntity(e);
    }

    engine.update(0);
  }

  void getEntities() {
    int numEntities = 10;

    Engine engine = Engine();

    List<Entity> entities = [];

    for (int i = 0; i < numEntities; ++i) {
      Entity entity = Entity();
      entities.add(entity);
      engine.addEntity(entity);
    }

    List<Entity?> engineEntities = engine.entities!;

    assertEquals(entities.length, engineEntities.length);

    for (int i = 0; i < numEntities; ++i) {
      assertEquals(entities[i], engineEntities[i]);
    }

    engine.removeAllEntities();

    assertEquals(0, engineEntities.length);
  }

  void addEntityTwice() {
    expect(() {
      Engine engine = Engine();
      Entity entity = Entity();
      engine.addEntity(entity);
      engine.addEntity(entity);
    }, throwsException);
  }

  void nestedUpdateException() {
    expect(() {
      final Engine engine = Engine();

      engine.addSystem(NestedUpdateExceptionEntitySystem());

      engine.update(deltaTime);
    }, throwsException);
  }

  void systemUpdateThrows() {
    Engine engine = Engine();

    EntitySystem system = SystemUpdateThrowsEntitySystem();

    engine.addSystem(system);

    bool thrown = false;

    try {
      engine.update(0.0);
    } on Exception {
      thrown = true;
    }

    assertTrue(thrown);

    engine.removeSystem(system);

    engine.update(0.0);
  }
}
