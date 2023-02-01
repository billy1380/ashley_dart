import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

abstract class ComponentRecorder {
  void addingComponentA();

  void removingComponentA();

  void addingComponentB();

  void removingComponentB();
}

class ComponentA implements Component {}

class ComponentB implements Component {}

class PositionComponent implements Component {}

class RemoveEntityListener implements EntityListener {
  final Engine _engine;

  const RemoveEntityListener(this._engine);

  void entityRemoved(Entity? entity) {
    _engine.addEntity(Entity());
  }

  void entityAdded(Entity? entity) {}
}

class AddEntityListener implements EntityListener {
  final Engine _engine;

  const AddEntityListener(this._engine);
  void entityRemoved(Entity? entity) {}

  void entityAdded(Entity? entity) {
    _engine.addEntity(Entity());
  }
}

class NoFamilyRemoveEntityListener implements EntityListener {
  final Engine _engine;
  final Family _family;

  const NoFamilyRemoveEntityListener(this._family, this._engine);

  void entityRemoved(Entity? entity) {
    if (_family.matches(entity!)) _engine.addEntity(Entity());
  }

  void entityAdded(Entity? entity) {}
}

class NoFamilyAddEntityListener implements EntityListener {
  final Engine _engine;
  final Family _family;

  const NoFamilyAddEntityListener(this._family, this._engine);

  void entityRemoved(Entity? entity) {}

  void entityAdded(Entity? entity) {
    if (_family.matches(entity!)) _engine.addEntity(Entity());
  }
}

class MockA extends Mock implements EntityListener {}

class MockB extends Mock implements EntityListener {}

class MockC extends Mock implements EntityListener {}

class MockComponentRecorder extends Mock implements ComponentRecorder {}

class ComponentHandlingEntityListener1 implements EntityListener {
  final ComponentRecorder recorder;

  const ComponentHandlingEntityListener1(this.recorder);

  @override
  void entityAdded(Entity? entity) {
    recorder.addingComponentA();
    entity!.add(ComponentA());
  }

  @override
  void entityRemoved(Entity? entity) {
    recorder.removingComponentA();
    entity!.remove(ComponentA);
  }
}

class ComponentHandlingEntityListener2 implements EntityListener {
  final ComponentRecorder recorder;

  const ComponentHandlingEntityListener2(this.recorder);

  @override
  void entityAdded(Entity? entity) {
    recorder.addingComponentB();
    entity!.add(ComponentB());
  }

  @override
  void entityRemoved(Entity? entity) {
    recorder.removingComponentB();
    entity!.remove(ComponentB);
  }
}

void main() {
  group("Entity Listener Tests", () {
    EntityListenerTests tests = EntityListenerTests();

    test("add entity listener family remove",
        tests.addEntityListenerFamilyRemove);
    test("add entity listener family add", tests.addEntityListenerFamilyAdd);
    test("add entity listener no family remove",
        tests.addEntityListenerNoFamilyRemove);
    test("add entity listener no family add",
        tests.addEntityListenerNoFamilyAdd);
    test("entity listener priority", tests.entityListenerPriority);
    test("family listener priority", tests.familyListenerPriority);
    test("component handling in listeners", tests.componentHandlingInListeners);
  });
}

class EntityListenerTests {
  void addEntityListenerFamilyRemove() {
    final Engine engine = Engine();

    Entity e = Entity();
    e.add(PositionComponent());
    engine.addEntity(e);

    Family family = Family.all([PositionComponent]).get();
    engine.addEntityListener(family, 0, RemoveEntityListener(engine));

    engine.removeEntity(e);
  }

  void addEntityListenerFamilyAdd() {
    final Engine engine = Engine();

    Entity e = Entity();
    e.add(PositionComponent());

    Family family = Family.all([PositionComponent]).get();
    engine.addEntityListener(family, 0, AddEntityListener(engine));

    engine.addEntity(e);
  }

  void addEntityListenerNoFamilyRemove() {
    final Engine engine = Engine();

    Entity e = Entity();
    e.add(PositionComponent());
    engine.addEntity(e);

    final Family family = Family.all([PositionComponent]).get();
    engine.addEntityListener(
        null, 0, NoFamilyRemoveEntityListener(family, engine));

    engine.removeEntity(e);
  }

  void addEntityListenerNoFamilyAdd() {
    final Engine engine = Engine();

    Entity e = Entity();
    e.add(PositionComponent());

    final Family family = Family.all([PositionComponent]).get();
    engine.addEntityListener(
        null, 0, NoFamilyAddEntityListener(family, engine));

    engine.addEntity(e);
  }

  void entityListenerPriority() {
    EntityListener a = MockA();
    EntityListener b = MockB();
    EntityListener c = MockC();

    Entity entity = Entity();
    Engine engine = Engine();
    engine.addEntityListener(null, -3, b);
    engine.addEntityListener(null, 0, c);
    engine.addEntityListener(null, -4, a);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.addEntity(entity);
    verifyInOrder(
        [a.entityAdded(entity), b.entityAdded(entity), c.entityAdded(entity)]);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.removeEntity(entity);
    verifyInOrder([
      a.entityRemoved(entity),
      b.entityRemoved(entity),
      c.entityRemoved(entity)
    ]);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.removeEntityListener(b);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.addEntity(entity);
    verifyInOrder([a.entityAdded(entity), c.entityAdded(entity)]);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.addEntityListener(null, 4, b);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);

    engine.removeEntity(entity);
    verifyInOrder([
      a.entityRemoved(entity),
      c.entityRemoved(entity),
      b.entityRemoved(entity)
    ]);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
    verifyNoMoreInteractions(c);
  }

  void familyListenerPriority() {
    EntityListener a = MockA();
    EntityListener b = MockB();

    Engine engine = Engine();
    engine.addEntityListener(Family.all([ComponentB]).get(), -2, b);
    engine.addEntityListener(Family.all([ComponentA]).get(), -3, a);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);

    Entity entity = Entity();
    entity.add(ComponentA());
    entity.add(ComponentB());

    engine.addEntity(entity);
    verifyInOrder([a.entityAdded(entity), b.entityAdded(entity)]);
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);

    entity.remove(ComponentB);
    verify(b.entityRemoved(entity));
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);

    entity.remove(ComponentA);
    verify(a.entityRemoved(entity));
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);

    entity.add(ComponentA());
    verify(a.entityAdded(entity));
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);

    entity.add(ComponentB());
    verify(b.entityAdded(entity));
    verifyNoMoreInteractions(a);
    verifyNoMoreInteractions(b);
  }

  void componentHandlingInListeners() {
    final Engine engine = Engine();

    final ComponentRecorder recorder = MockComponentRecorder();

    engine.addEntityListener(
        null, 0, ComponentHandlingEntityListener1(recorder));

    engine.addEntityListener(
        null, 0, ComponentHandlingEntityListener2(recorder));

    engine.update(0);
    Entity e = Entity();
    engine.addEntity(e);
    engine.update(0);
    engine.removeEntity(e);
    engine.update(0);

    verify(recorder.addingComponentA());
    verify(recorder.removingComponentA());
    verify(recorder.addingComponentB());
    verify(recorder.removingComponentB());
  }
}
