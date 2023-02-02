import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

import '../helpers.dart';

class SystemListenerSpy implements SystemListener {
  int addedCount = 0;
  int removedCount = 0;

  @override
  void systemAdded(EntitySystem system) {
    system.addedToEngine(null);
    ++addedCount;
  }

  @override
  void systemRemoved(EntitySystem system) {
    system.removedFromEngine(null);
    removedCount++;
  }
}

class EntitySystemMock extends EntitySystem {
  int addedCalls = 0;
  int removedCalls = 0;

  List<int>? updates;

  EntitySystemMock(this.updates);

  @override
  void update(double deltaTime) {
    if (updates != null) {
      updates!.add(priority);
    }
  }

  @override
  void addedToEngine(Engine? engine) {
    ++addedCalls;
  }

  @override
  void removedFromEngine(Engine? engine) {
    ++removedCalls;
  }
}

class EntitySystemMockA extends EntitySystemMock {
  EntitySystemMockA([List<int>? updates]) : super(updates);
}

class EntitySystemMockB extends EntitySystemMock {
  EntitySystemMockB([List<int>? updates]) : super(updates);
}

void main() {
  group("System Manager Tests", () {
    SystemManagerTests tests = SystemManagerTests();

    test("add and remove system", tests.addAndRemoveSystem);
    test("get systems", tests.getSystems);
    test("add two systems of same class", tests.addTwoSystemsOfSameClass);
    test("system update order", tests.systemUpdateOrder);
  });
}

class SystemManagerTests {
  void addAndRemoveSystem() {
    EntitySystemMockA systemA = EntitySystemMockA();
    EntitySystemMockB systemB = EntitySystemMockB();

    SystemListenerSpy systemSpy = SystemListenerSpy();
    SystemManager manager = SystemManager(systemSpy);

    assertNull(manager.getSystem(EntitySystemMockA));
    assertNull(manager.getSystem(EntitySystemMockB));

    manager.addSystem(systemA);
    manager.addSystem(systemB);

    assertNotNull(manager.getSystem(EntitySystemMockA));
    assertNotNull(manager.getSystem(EntitySystemMockB));
    assertEquals(1, systemA.addedCalls);
    assertEquals(1, systemB.addedCalls);

    manager.removeSystem(systemA);
    manager.removeSystem(systemB);

    assertNull(manager.getSystem(EntitySystemMockA));
    assertNull(manager.getSystem(EntitySystemMockB));
    assertEquals(1, systemA.removedCalls);
    assertEquals(1, systemB.removedCalls);

    manager.addSystem(systemA);
    manager.addSystem(systemB);
    manager.removeAllSystems();

    assertNull(manager.getSystem(EntitySystemMockA));
    assertNull(manager.getSystem(EntitySystemMockB));
    assertEquals(2, systemA.removedCalls);
    assertEquals(2, systemB.removedCalls);
  }

  void getSystems() {
    SystemListenerSpy systemSpy = SystemListenerSpy();
    SystemManager manager = SystemManager(systemSpy);
    EntitySystemMockA systemA = EntitySystemMockA();
    EntitySystemMockB systemB = EntitySystemMockB();

    assertEquals(0, manager.systems!.length);

    manager.addSystem(systemA);
    manager.addSystem(systemB);

    assertEquals(2, manager.systems!.length);
    assertEquals(2, systemSpy.addedCount);

    manager.removeSystem(systemA);
    manager.removeSystem(systemB);

    assertEquals(0, manager.systems!.length);
    assertEquals(2, systemSpy.addedCount);
    assertEquals(2, systemSpy.removedCount);
  }

  void addTwoSystemsOfSameClass() {
    SystemListenerSpy systemSpy = SystemListenerSpy();
    SystemManager manager = SystemManager(systemSpy);
    EntitySystemMockA system1 = EntitySystemMockA();
    EntitySystemMockA system2 = EntitySystemMockA();

    assertEquals(0, manager.systems!.length);

    manager.addSystem(system1);

    assertEquals(1, manager.systems!.length);
    assertEquals(system1, manager.getSystem(EntitySystemMockA));
    assertEquals(1, systemSpy.addedCount);

    manager.addSystem(system2);

    assertEquals(1, manager.systems!.length);
    assertEquals(system2, manager.getSystem(EntitySystemMockA));
    assertEquals(2, systemSpy.addedCount);
    assertEquals(1, systemSpy.removedCount);
  }

  void systemUpdateOrder() {
    List<int> updates = [];

    SystemListenerSpy systemSpy = SystemListenerSpy();
    SystemManager manager = SystemManager(systemSpy);
    EntitySystemMock system1 = EntitySystemMockA(updates);
    EntitySystemMock system2 = EntitySystemMockB(updates);

    system1.priority = 2;
    system2.priority = 1;

    manager.addSystem(system1);
    manager.addSystem(system2);

    List<EntitySystem> systems = manager.systems!;
    assertEquals(system2, systems[0]);
    assertEquals(system1, systems[1]);
  }
}
