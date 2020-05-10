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

void main() {
  group("ComponentTypeTests", () {
    ComponentTypeTests tests = ComponentTypeTests();

    test("validComponent type", tests.validComponentType);
    test("sameComponent type", tests.sameComponentType);
    test("differentComponent type", tests.differentComponentType);
  });
}

class ComponentTypeTests {
  void validComponentType() {
    assertNotNull(ComponentType.getFor(ComponentA));
    assertNotNull(ComponentType.getFor(ComponentB));
  }

  void sameComponentType() {
    ComponentType componentType1 = ComponentType.getFor(ComponentA);
    ComponentType componentType2 = ComponentType.getFor(ComponentA);

    assertEquals(true, componentType1 == componentType2);
    assertEquals(true, componentType2 == componentType1);
    assertEquals(componentType1.index, componentType2.index);
    assertEquals(componentType1.index, ComponentType.getIndexFor(ComponentA));
    assertEquals(componentType2.index, ComponentType.getIndexFor(ComponentA));
  }

  void differentComponentType() {
    ComponentType componentType1 = ComponentType.getFor(ComponentA);
    ComponentType componentType2 = ComponentType.getFor(ComponentB);

    assertEquals(false, componentType1 == componentType2);
    assertEquals(false, componentType2 == componentType1);
    assertNotEquals(componentType1.index, componentType2.index);
    assertNotEquals(
        componentType1.index, ComponentType.getIndexFor(ComponentB));
    assertNotEquals(
        componentType2.index, ComponentType.getIndexFor(ComponentA));
  }
}
