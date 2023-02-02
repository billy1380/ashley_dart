import '../helpers.dart';
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

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

void main() {
  group("Entity Manager Tests", () {
    EntityManagerTests tests = EntityManagerTests();

    test("add And Remove Entity", tests.addAndRemoveEntity);
    test("get Entities", tests.getEntities);
    test("add Entity Twice 1", tests.addEntityTwice1);
    test("add Entity Twice 2", tests.addEntityTwice2);
    test("add Entity Twice Delayed", tests.addEntityTwiceDelayed);
    test("delayed Operations Order", tests.delayedOperationsOrder);
    test("remove And Add Entity Delayed", tests.removeAndAddEntityDelayed);
    test("remove All And Add Entity Delayed",
        tests.removeAllAndAddEntityDelayed);
  });
}

class EntityManagerTests {
  void addAndRemoveEntity() {
    EntityListenerMock listener = EntityListenerMock();
    EntityManager manager = EntityManager(listener);

    Entity entity1 = Entity();
    manager.addEntity(entity1);

    assertEquals(1, listener.addedCount);
    Entity entity2 = Entity();
    manager.addEntity(entity2);

    assertEquals(2, listener.addedCount);

    manager.removeAllEntities();

    assertEquals(2, listener.removedCount);
  }

  void getEntities() {
    int numEntities = 10;

    EntityListenerMock listener = EntityListenerMock();
    EntityManager manager = EntityManager(listener);

    List<Entity> entities = [];

    for (int i = 0; i < numEntities; ++i) {
      Entity entity = Entity();
      entities.add(entity);
      manager.addEntity(entity);
    }

    List<Entity?> engineEntities = manager.entities!;

    assertEquals(entities.length, engineEntities.length);

    for (int i = 0; i < numEntities; ++i) {
      assertEquals(entities[i], engineEntities[i]);
    }

    manager.removeAllEntities();

    assertEquals(0, engineEntities.length);
  }

  void addEntityTwice1() {
    expect(() {
      EntityListenerMock listener = EntityListenerMock();
      EntityManager manager = EntityManager(listener);
      Entity entity = Entity();
      manager.addEntity(entity);
      manager.addEntity(entity);
    }, throwsException);
  }

  void addEntityTwice2() {
    expect(() {
      EntityListenerMock listener = EntityListenerMock();
      EntityManager manager = EntityManager(listener);
      Entity entity = Entity();
      manager.addEntity(entity, false);
      manager.addEntity(entity, false);
    }, throwsException);
  }

  void addEntityTwiceDelayed() {
    expect(() {
      EntityListenerMock listener = EntityListenerMock();
      EntityManager manager = EntityManager(listener);

      Entity entity = Entity();
      manager.addEntity(entity, true);
      manager.addEntity(entity, true);
      manager.processPendingOperations();
    }, throwsException);
  }

  void delayedOperationsOrder() {
    EntityListenerMock listener = EntityListenerMock();
    EntityManager manager = EntityManager(listener);

    Entity entityA = Entity();
    Entity entityB = Entity();

    bool delayed = true;
    manager.addEntity(entityA);
    manager.addEntity(entityB);

    assertEquals(2, manager.entities!.length);

    Entity entityC = Entity();
    Entity entityD = Entity();
    manager.removeAllEntities(null, delayed);
    manager.addEntity(entityC, delayed);
    manager.addEntity(entityD, delayed);
    manager.processPendingOperations();

    assertEquals(2, manager.entities!.length);
    assertNotEquals(-1, manager.entities!.indexOf(entityC));
    assertNotEquals(-1, manager.entities!.indexOf(entityD));
  }

  void removeAndAddEntityDelayed() {
    EntityListenerMock listener = EntityListenerMock();
    EntityManager manager = EntityManager(listener);

    Entity entity = Entity();
    manager.addEntity(entity, false); // immediate
    assertEquals(1, manager.entities!.length);

    manager.removeEntity(entity, true); // delayed
    assertEquals(1, manager.entities!.length);

    manager.addEntity(entity, true); // delayed
    assertEquals(1, manager.entities!.length);

    manager.processPendingOperations();
    assertEquals(1, manager.entities!.length);
  }

  void removeAllAndAddEntityDelayed() {
    EntityListenerMock listener = EntityListenerMock();
    EntityManager manager = EntityManager(listener);

    Entity entity = Entity();
    manager.addEntity(entity, false); // immediate
    assertEquals(1, manager.entities!.length);

    manager.removeAllEntities(null, true); // delayed
    assertEquals(1, manager.entities!.length);

    manager.addEntity(entity, true); // delayed
    assertEquals(1, manager.entities!.length);

    manager.processPendingOperations();
    assertEquals(1, manager.entities!.length);
  }
}
