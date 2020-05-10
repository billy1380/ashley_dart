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

class EntityListenerMock implements Listener<Entity> {
  int counter = 0;

  @override
  void receive(Signal<Entity> signal, Entity object) {
    ++counter;

    assertNotNull(signal);
    assertNotNull(object);
  }
}

void main() {
  group("Entity Tests", () {
    EntityTests tests = EntityTests();

    test("add and return component", tests.addAndReturnComponent);
    test("no components", tests.noComponents);
    test("add and remove component", tests.addAndRemoveComponent);
    test("add and remove all components", tests.addAndRemoveAllComponents);
    test("add same component", tests.addSameComponent);
    test("component listener", tests.componentListener);
    test("get component by class", tests.getComponentByClass);
  });
}

class EntityTests {
  ComponentMapper<ComponentA> _am = ComponentMapper.getFor(ComponentA);
  ComponentMapper<ComponentB> _bm = ComponentMapper.getFor(ComponentB);

  void addAndReturnComponent() {
    Entity entity = Entity();
    ComponentA componentA = ComponentA();
    ComponentB componentB = ComponentB();

    assertEquals(componentA, entity.addAndReturn(componentA));
    assertEquals(componentB, entity.addAndReturn(componentB));

    assertEquals(2, entity.components.length);
  }

  void noComponents() {
    Entity entity = Entity();

    assertEquals(0, entity.components.length);
    assertTrue(entity.componentBits.isEmpty);
    assertNull(_am[entity]);
    assertNull(_bm[entity]);
    assertFalse(_am.has(entity));
    assertFalse(_bm.has(entity));
  }

  void addAndRemoveComponent() {
    Entity entity = Entity();

    entity.add(ComponentA());

    assertEquals(1, entity.components.length);

    Bits componentBits = entity.componentBits;
    int componentAIndex = ComponentType.getIndexFor(ComponentA);

    for (int i = 0; i < componentBits.length; ++i) {
      assertEquals(i == componentAIndex, componentBits[i]);
    }

    assertNotNull(_am[entity]);
    assertNull(_bm[entity]);
    assertTrue(_am.has(entity));
    assertFalse(_bm.has(entity));

    entity.remove(ComponentA);

    assertEquals(0, entity.components.length);

    for (int i = 0; i < componentBits.length; ++i) {
      assertFalse(componentBits[i]);
    }

    assertNull(_am[entity]);
    assertNull(_bm[entity]);
    assertFalse(_am.has(entity));
    assertFalse(_bm.has(entity));
  }

  void addAndRemoveAllComponents() {
    Entity entity = Entity();

    entity.add(ComponentA());
    entity.add(ComponentB());

    assertEquals(2, entity.components.length);

    Bits componentBits = entity.componentBits;
    int componentAIndex = ComponentType.getIndexFor(ComponentA);
    int componentBIndex = ComponentType.getIndexFor(ComponentB);

    for (int i = 0; i < componentBits.length; ++i) {
      assertEquals(
          i == componentAIndex || i == componentBIndex, componentBits[i]);
    }

    assertNotNull(_am[entity]);
    assertNotNull(_bm[entity]);
    assertTrue(_am.has(entity));
    assertTrue(_bm.has(entity));

    entity.removeAll();

    assertEquals(0, entity.components.length);

    for (int i = 0; i < componentBits.length; ++i) {
      assertFalse(componentBits[i]);
    }

    assertNull(_am[entity]);
    assertNull(_bm[entity]);
    assertFalse(_am.has(entity));
    assertFalse(_bm.has(entity));
  }

  void addSameComponent() {
    Entity entity = Entity();

    ComponentA a1 = ComponentA();
    ComponentA a2 = ComponentA();

    entity.add(a1);
    entity.add(a2);

    assertEquals(1, entity.components.length);
    assertTrue(_am.has(entity));
    assertNotEquals(a1, _am[entity]);
    assertEquals(a2, _am[entity]);
  }

  void componentListener() {
    EntityListenerMock addedListener = EntityListenerMock();
    EntityListenerMock removedListener = EntityListenerMock();

    Entity entity = Entity();
    entity.componentAdded.add(addedListener);
    entity.componentRemoved.add(removedListener);

    assertEquals(0, addedListener.counter);
    assertEquals(0, removedListener.counter);

    entity.add(ComponentA());

    assertEquals(1, addedListener.counter);
    assertEquals(0, removedListener.counter);

    entity.remove(ComponentA);

    assertEquals(1, addedListener.counter);
    assertEquals(1, removedListener.counter);

    entity.add(ComponentB());

    assertEquals(2, addedListener.counter);

    entity.remove(ComponentB);

    assertEquals(2, removedListener.counter);
  }

  void getComponentByClass() {
    ComponentA compA = ComponentA();
    ComponentB compB = ComponentB();

    Entity entity = Entity();
    entity.add(compA).add(compB);

    ComponentA retA = entity.getComponent(ComponentA);
    ComponentB retB = entity.getComponent(ComponentB);

    assertNotNull(retA);
    assertNotNull(retB);

    assertTrue(retA == compA);
    assertTrue(retB == compB);
  }
}
