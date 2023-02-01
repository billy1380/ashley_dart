import '../helpers.dart';
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';

class ComponentA implements Component {}

class ComponentB implements Component {}

class ComponentC implements Component {}

class ThrowingListener implements EntityListener {
  @override
  void entityAdded(Entity? entity) {
    throw new Exception("throwing");
  }

  @override
  void entityRemoved(Entity? entity) {
    throw new Exception("throwing");
  }
}

void main() {
  group("Family Manager Tests", () {
    FamilyManagerTests tests = FamilyManagerTests();

    test("entities for family", tests.entitiesForFamily);
    test("entity for family with removal", tests.entityForFamilyWithRemoval);
    test("entities for family after", tests.entitiesForFamilyAfter);
    test(
        "entities for family with removal", tests.entitiesForFamilyWithRemoval);
    test("entities for family with removal and filtering",
        tests.entitiesForFamilyWithRemovalAndFiltering);
    test("entity listener throws", tests.entityListenerThrows);
  });
}

class FamilyManagerTests {
  void entitiesForFamily() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = manager[family];

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

    entities.add(entity1);
    entities.add(entity2);
    entities.add(entity3);
    entities.add(entity4);

    manager.updateFamilyMembership(entity1);
    manager.updateFamilyMembership(entity2);
    manager.updateFamilyMembership(entity3);
    manager.updateFamilyMembership(entity4);

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));
  }

  void entityForFamilyWithRemoval() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    Entity entity = Entity();
    entity.add(ComponentA());

    entities.add(entity);

    manager.updateFamilyMembership(entity);

    List<Entity?> familyEntities =
        manager[Family.all([ComponentA]).get()];

    assertEquals(1, familyEntities.length);
    assertTrue(familyEntities.contains(entity));

    entity.removing = true;
    entities.remove(entity);

    manager.updateFamilyMembership(entity);
    entity.removing = false;

    assertEquals(0, familyEntities.length);
    assertFalse(familyEntities.contains(entity));
  }

  void entitiesForFamilyAfter() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = manager[family];

    assertEquals(0, familyEntities.length);

    Entity entity1 = Entity();
    Entity entity2 = Entity();
    Entity entity3 = Entity();
    Entity entity4 = Entity();

    entities.add(entity1);
    entities.add(entity2);
    entities.add(entity3);
    entities.add(entity4);

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

    manager.updateFamilyMembership(entity1);
    manager.updateFamilyMembership(entity2);
    manager.updateFamilyMembership(entity3);
    manager.updateFamilyMembership(entity4);

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));
  }

  void entitiesForFamilyWithRemoval() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    Family family = Family.all([ComponentA, ComponentB]).get();
    List<Entity?> familyEntities = manager[family];

    Entity entity1 = Entity();
    Entity entity2 = Entity();
    Entity entity3 = Entity();
    Entity entity4 = Entity();

    entities.add(entity1);
    entities.add(entity2);
    entities.add(entity3);
    entities.add(entity4);

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

    manager.updateFamilyMembership(entity1);
    manager.updateFamilyMembership(entity2);
    manager.updateFamilyMembership(entity3);
    manager.updateFamilyMembership(entity4);

    assertEquals(3, familyEntities.length);
    assertTrue(familyEntities.contains(entity1));
    assertTrue(familyEntities.contains(entity3));
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity2));

    entity1.remove(ComponentA);
    entity3.removing = true;
    entities.remove(entity3);

    manager.updateFamilyMembership(entity1);
    manager.updateFamilyMembership(entity3);

    entity3.removing = false;

    assertEquals(1, familyEntities.length);
    assertTrue(familyEntities.contains(entity4));
    assertFalse(familyEntities.contains(entity1));
    assertFalse(familyEntities.contains(entity3));
    assertFalse(familyEntities.contains(entity2));
  }

  void entitiesForFamilyWithRemovalAndFiltering() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    List<Entity?> entitiesWithComponentAOnly = manager
        [Family.all([ComponentA]).exclude([ComponentB]).get()];

    List<Entity?> entitiesWithComponentB =
        manager[Family.all([ComponentB]).get()];

    Entity entity1 = Entity();
    Entity entity2 = Entity();

    entities.add(entity1);
    entities.add(entity2);

    entity1.add(ComponentA());

    entity2.add(ComponentA());
    entity2.add(ComponentB());

    manager.updateFamilyMembership(entity1);
    manager.updateFamilyMembership(entity2);

    assertEquals(1, entitiesWithComponentAOnly.length);
    assertEquals(1, entitiesWithComponentB.length);

    entity2.remove(ComponentB);

    manager.updateFamilyMembership(entity2);

    assertEquals(2, entitiesWithComponentAOnly.length);
    assertEquals(0, entitiesWithComponentB.length);
  }

  void entityListenerThrows() {
    List<Entity> entities = [];
    List<Entity> immutableEntities = List.unmodifiable(entities);
    FamilyManager manager = FamilyManager(immutableEntities);

    EntityListener listener = ThrowingListener();

    manager.addEntityListener(Family.all([]).get(), 0, listener);

    Entity entity = Entity();
    entities.add(entity);

    bool thrown = false;
    try {
      manager.updateFamilyMembership(entity);
    } on Exception {
      thrown = true;
    }

    assertTrue(thrown);
    assertFalse(manager.notifying);
  }
}
