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

class ComponentA implements Component {}

class ComponentB implements Component {}

class ComponentC implements Component {}

class ComponentD implements Component {}

class ComponentE implements Component {}

class ComponentF implements Component {}

class TestSystemA extends IteratingSystem {
  TestSystemA(String name) : super(Family.all([ComponentA]).get());

  @override
  void processEntity(Entity? e, double d) {}
}

class TestSystemB extends IteratingSystem {
  TestSystemB(String name) : super(Family.all([ComponentB]).get());

  @override
  void processEntity(Entity? e, double d) {}
}

void main() {
  group("Family Tests", () {
    FamilyTests tests = FamilyTests();

    test("valid family", tests.validFamily);
    test("same family", tests.sameFamily);
    test("different family", tests.differentFamily);
    test("family equality filtering", tests.familyEqualityFiltering);
    test("entity match", tests.entityMatch);
    test("entity mismatch", tests.entityMismatch);
    test("entity match then mismatch", tests.entityMatchThenMismatch);
    test("entity mismatch then match", tests.entityMismatchThenMatch);
    test("test empty family", tests.testEmptyFamily);
    test("family filtering", tests.familyFiltering);
    test("match without systems", tests.matchWithoutSystems);
    test("match with complex building", tests.matchWithComplexBuilding);
  });
}

class FamilyTests {
  void validFamily() {
    assertNotNull(Family.all([]).get());
    assertNotNull(Family.all([ComponentA]).get());
    assertNotNull(Family.all([ComponentB]).get());
    assertNotNull(Family.all([ComponentC]).get());
    assertNotNull(Family.all([ComponentA, ComponentB]).get());
    assertNotNull(Family.all([ComponentA, ComponentC]).get());
    assertNotNull(Family.all([ComponentB, ComponentA]).get());
    assertNotNull(Family.all([ComponentB, ComponentC]).get());
    assertNotNull(Family.all([ComponentC, ComponentA]).get());
    assertNotNull(Family.all([ComponentC, ComponentB]).get());
    assertNotNull(Family.all([ComponentA, ComponentB, ComponentC]).get());
    assertNotNull(Family.all([ComponentA, ComponentB])
        .one([ComponentC, ComponentD]).exclude([ComponentE, ComponentF]).get());
  }

  void sameFamily() {
    Family family1 = Family.all([ComponentA]).get();
    Family family2 = Family.all([ComponentA]).get();
    Family family3 = Family.all([ComponentA, ComponentB]).get();
    Family family4 = Family.all([ComponentA, ComponentB]).get();
    Family family5 = Family.all([ComponentA, ComponentB, ComponentC]).get();
    Family family6 = Family.all([ComponentA, ComponentB, ComponentC]).get();
    Family family7 = Family.all([ComponentA, ComponentB])
        .one([ComponentC, ComponentD]).exclude([ComponentE, ComponentF]).get();
    Family family8 = Family.all([ComponentA, ComponentB])
        .one([ComponentC, ComponentD]).exclude([ComponentE, ComponentF]).get();
    Family family9 = Family.all([]).get();
    Family family10 = Family.all([]).get();

    assertTrue(family1 == family2);
    assertTrue(family2 == family1);
    assertTrue(family3 == family4);
    assertTrue(family4 == family3);
    assertTrue(family5 == family6);
    assertTrue(family6 == family5);
    assertTrue(family7 == family8);
    assertTrue(family8 == family7);
    assertTrue(family9 == family10);

    assertEquals(family1.index, family2.index);
    assertEquals(family3.index, family4.index);
    assertEquals(family5.index, family6.index);
    assertEquals(family7.index, family8.index);
    assertEquals(family9.index, family10.index);
  }

  void differentFamily() {
    Family family1 = Family.all([ComponentA]).get();
    Family family2 = Family.all([ComponentB]).get();
    Family family3 = Family.all([ComponentC]).get();
    Family family4 = Family.all([ComponentA, ComponentB]).get();
    Family family5 = Family.all([ComponentA, ComponentC]).get();
    Family family6 = Family.all([ComponentB, ComponentA]).get();
    Family family7 = Family.all([ComponentB, ComponentC]).get();
    Family family8 = Family.all([ComponentC, ComponentA]).get();
    Family family9 = Family.all([ComponentC, ComponentB]).get();
    Family family10 = Family.all([ComponentA, ComponentB, ComponentC]).get();
    Family family11 = Family.all([ComponentA, ComponentB])
        .one([ComponentC, ComponentD]).exclude([ComponentE, ComponentF]).get();
    Family family12 = Family.all([ComponentC, ComponentD])
        .one([ComponentE, ComponentF]).exclude([ComponentA, ComponentB]).get();
    Family family13 = Family.all([]).get();

    assertFalse(family1 == family2);
    assertFalse(family1 == family3);
    assertFalse(family1 == family4);
    assertFalse(family1 == family5);
    assertFalse(family1 == family6);
    assertFalse(family1 == family7);
    assertFalse(family1 == family8);
    assertFalse(family1 == family9);
    assertFalse(family1 == family10);
    assertFalse(family1 == family11);
    assertFalse(family1 == family12);
    assertFalse(family1 == family13);

    assertFalse(family10 == family1);
    assertFalse(family10 == family2);
    assertFalse(family10 == family3);
    assertFalse(family10 == family4);
    assertFalse(family10 == family5);
    assertFalse(family10 == family6);
    assertFalse(family10 == family7);
    assertFalse(family10 == family8);
    assertFalse(family10 == family9);
    assertFalse(family11 == family12);
    assertFalse(family10 == family13);

    assertNotEquals(family1.index, family2.index);
    assertNotEquals(family1.index, family3.index);
    assertNotEquals(family1.index, family4.index);
    assertNotEquals(family1.index, family5.index);
    assertNotEquals(family1.index, family6.index);
    assertNotEquals(family1.index, family7.index);
    assertNotEquals(family1.index, family8.index);
    assertNotEquals(family1.index, family9.index);
    assertNotEquals(family1.index, family10.index);
    assertNotEquals(family11.index, family12.index);
    assertNotEquals(family1.index, family13.index);
  }

  void familyEqualityFiltering() {
    Family family1 =
        Family.all([ComponentA]).one([ComponentB]).exclude([ComponentC]).get();
    Family family2 =
        Family.all([ComponentB]).one([ComponentC]).exclude([ComponentA]).get();
    Family family3 =
        Family.all([ComponentC]).one([ComponentA]).exclude([ComponentB]).get();
    Family family4 =
        Family.all([ComponentA]).one([ComponentB]).exclude([ComponentC]).get();
    Family family5 =
        Family.all([ComponentB]).one([ComponentC]).exclude([ComponentA]).get();
    Family family6 =
        Family.all([ComponentC]).one([ComponentA]).exclude([ComponentB]).get();

    assertTrue(family1 == family4);
    assertTrue(family2 == family5);
    assertTrue(family3 == family6);
    assertFalse(family1 == family2);
    assertFalse(family1 == family3);
  }

  void entityMatch() {
    Family family = Family.all([ComponentA, ComponentB]).get();

    Entity entity = Entity();
    entity.add(ComponentA());
    entity.add(ComponentB());

    assertTrue(family.matches(entity));

    entity.add(ComponentC());

    assertTrue(family.matches(entity));
  }

  void entityMismatch() {
    Family family = Family.all([ComponentA, ComponentC]).get();

    Entity entity = Entity();
    entity.add(ComponentA());
    entity.add(ComponentB());

    assertFalse(family.matches(entity));

    entity.remove(ComponentB);

    assertFalse(family.matches(entity));
  }

  void entityMatchThenMismatch() {
    Family family = Family.all([ComponentA, ComponentB]).get();

    Entity entity = Entity();
    entity.add(ComponentA());
    entity.add(ComponentB());

    assertTrue(family.matches(entity));

    entity.remove(ComponentA);

    assertFalse(family.matches(entity));
  }

  void entityMismatchThenMatch() {
    Family family = Family.all([ComponentA, ComponentB]).get();

    Entity entity = Entity();
    entity.add(ComponentA());
    entity.add(ComponentC());

    assertFalse(family.matches(entity));

    entity.add(ComponentB());

    assertTrue(family.matches(entity));
  }

  void testEmptyFamily() {
    Family family = Family.all([]).get();
    Entity entity = Entity();
    assertTrue(family.matches(entity));
  }

  void familyFiltering() {
    Family family1 = Family.all([ComponentA, ComponentB])
        .one([ComponentC, ComponentD]).exclude([ComponentE, ComponentF]).get();

    Family family2 = Family.all([ComponentC, ComponentD])
        .one([ComponentA, ComponentB]).exclude([ComponentE, ComponentF]).get();

    Entity entity = Entity();

    assertFalse(family1.matches(entity));
    assertFalse(family2.matches(entity));

    entity.add(ComponentA());
    entity.add(ComponentB());

    assertFalse(family1.matches(entity));
    assertFalse(family2.matches(entity));

    entity.add(ComponentC());

    assertTrue(family1.matches(entity));
    assertFalse(family2.matches(entity));

    entity.add(ComponentD());

    assertTrue(family1.matches(entity));
    assertTrue(family2.matches(entity));

    entity.add(ComponentE());

    assertFalse(family1.matches(entity));
    assertFalse(family2.matches(entity));

    entity.remove(ComponentE);

    assertTrue(family1.matches(entity));
    assertTrue(family2.matches(entity));

    entity.remove(ComponentA);

    assertFalse(family1.matches(entity));
    assertTrue(family2.matches(entity));
  }

  void matchWithoutSystems() {
    Engine engine = Engine();

    Entity e = new Entity();
    e.add(ComponentB());
    e.add(ComponentA());
    engine.addEntity(e);

    Family f = Family.all([ComponentB]).exclude([ComponentA]).get();

    assertFalse(f.matches(e));
  }

  void matchWithComplexBuilding() {
    Family family =
        Family.all([ComponentB]).one([ComponentA]).exclude([ComponentC]).get();
    Entity entity = Entity().add(ComponentA());
    assertFalse(family.matches(entity));
    entity.add(ComponentB());
    assertTrue(family.matches(entity));
    entity.add(ComponentC());
    assertFalse(family.matches(entity));
  }
}
