import '../helpers.dart';
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

class BooleanInformerMock implements BooleanInformer {
  bool delayed = false;

  @override
  bool get value {
    return delayed;
  }
}

class ComponentSpy implements Listener<Entity> {
  bool called = false;

  @override
  void receive(Signal<Entity> signal, Entity object) {
    called = true;
  }
}

void main() {
  group("Component Operation Handler Tests", () {
    ComponentOperationHandlerTests tests = ComponentOperationHandlerTests();

    test("add", tests.add);
    test("add delayed", tests.addDelayed);
    test("remove", tests.remove);
    test("remove delayed", tests.removeDelayed);
  });
}

class ComponentOperationHandlerTests {
  void add() {
    ComponentSpy spy = ComponentSpy();
    BooleanInformerMock informer = BooleanInformerMock();
    ComponentOperationHandler handler = ComponentOperationHandler(informer);

    Entity entity = Entity();
    entity.componentOperationHandler = handler;
    entity.componentAdded.add(spy);

    handler.add(entity);

    assertTrue(spy.called);
  }

  void addDelayed() {
    ComponentSpy spy = ComponentSpy();
    BooleanInformerMock informer = BooleanInformerMock();
    ComponentOperationHandler handler = ComponentOperationHandler(informer);

    informer.delayed = true;

    Entity entity = Entity();
    entity.componentOperationHandler = handler;
    entity.componentAdded.add(spy);

    handler.add(entity);

    assertFalse(spy.called);
    handler.processOperations();
    assertTrue(spy.called);
  }

  void remove() {
    ComponentSpy spy = ComponentSpy();
    BooleanInformerMock informer = BooleanInformerMock();
    ComponentOperationHandler handler = ComponentOperationHandler(informer);

    Entity entity = Entity();
    entity.componentOperationHandler = handler;
    entity.componentRemoved.add(spy);

    handler.remove(entity);

    assertTrue(spy.called);
  }

  void removeDelayed() {
    ComponentSpy spy = ComponentSpy();
    BooleanInformerMock informer = BooleanInformerMock();
    ComponentOperationHandler handler = ComponentOperationHandler(informer);

    informer.delayed = true;

    Entity entity = Entity();
    entity.componentOperationHandler = handler;
    entity.componentRemoved.add(spy);

    handler.remove(entity);

    assertFalse(spy.called);
    handler.processOperations();
    assertTrue(spy.called);
  }
}
