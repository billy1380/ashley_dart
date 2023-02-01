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

import 'package:ashley_dart/utils/bits.dart';
import 'package:ashley_dart/core/component_type.dart';
import 'package:ashley_dart/core/entity.dart';

class FamilyBuilder {
  Bits _all = Family._zeroBits;
  Bits _one = Family._zeroBits;
  Bits _exclude = Family._zeroBits;

  /**
		 * Resets the builder instance
		 * @return A Builder singleton instance to get a family
		 */
  FamilyBuilder reset() {
    _all = Family._zeroBits;
    _one = Family._zeroBits;
    _exclude = Family._zeroBits;
    return this;
  }

  /**
		 * @param componentTypes entities will have to contain all of the specified components.
		 * @return A Builder singleton instance to get a family
		 */

  FamilyBuilder all(List<Type> componentTypes) {
    _all = ComponentType.getBitsFor(componentTypes);
    return this;
  }

  /**
		 * @param componentTypes entities will have to contain at least one of the specified components.
		 * @return A Builder singleton instance to get a family
		 */
  FamilyBuilder one(List<Type> componentTypes) {
    _one = ComponentType.getBitsFor(componentTypes);
    return this;
  }

  /**
		 * @param componentTypes entities cannot contain any of the specified components.
		 * @return A Builder singleton instance to get a family
		 */
  FamilyBuilder exclude(List<Type> componentTypes) {
    _exclude = ComponentType.getBitsFor(componentTypes);
    return this;
  }

  /** @return A family for the configured component types */
  Family get() {
    String hash = Family._getFamilyHash(_all, _one, _exclude);
    Family? family = Family._families[hash];
    if (family == null) {
      family = Family._(_all, _one, _exclude);
      Family._families[hash] = family;
    }
    return family;
  }
}

/**
 * Represents a group of {@link Component}s. It is used to describe what {@link Entity} objects an {@link EntitySystem} should
 * process. Example: {@code Family.all(PositionComponent, VelocityComponent).get()} Families can't be instantiated
 * directly but must be accessed via a builder ( start with {@code Family.all()}, {@code Family.one()} or {@code Family.exclude()}
 * ), this is to avoid duplicate families that describe the same components.
 * @author Stefan Bachmann
 */
class Family {
  static Map<String, Family> _families = {};
  static int _familyIndex = 0;
  static final FamilyBuilder _builder = FamilyBuilder();
  static final Bits _zeroBits = Bits();

  final Bits _all;
  final Bits _one;
  final Bits _exclude;
  final int _index;

  /** private constructor, use static method Family.getFamilyFor() */
  Family._(this._all, this._one, this._exclude) : this._index = _familyIndex++;

  /** @return This family's unique index */
  int get index {
    return this._index;
  }

  /** @return Whether the entity matches the family requirements or not */
  bool matches(Entity entity) {
    Bits entityComponentBits = entity.componentBits!;

    if (!entityComponentBits.containsAll(_all)) {
      return false;
    }

    if (!_one.isEmpty && !_one.intersects(entityComponentBits)) {
      return false;
    }

    if (!_exclude.isEmpty && _exclude.intersects(entityComponentBits)) {
      return false;
    }

    return true;
  }

  /**
	 * @param componentTypes entities will have to contain all of the specified components.
	 * @return A Builder singleton instance to get a family
	 */

  static FamilyBuilder all(List<Type> componentTypes) {
    return _builder.reset().all(componentTypes);
  }

  /**
	 * @param componentTypes entities will have to contain at least one of the specified components.
	 * @return A Builder singleton instance to get a family
	 */
  static FamilyBuilder one(List<Type> componentTypes) {
    return _builder.reset().one(componentTypes);
  }

  /**
	 * @param componentTypes entities cannot contain any of the specified components.
	 * @return A Builder singleton instance to get a family
	 */
  static FamilyBuilder exclude(List<Type> componentTypes) {
    return _builder.reset().exclude(componentTypes);
  }

  @override
  int get hashCode {
    return index;
  }

  @override
  bool operator ==(dynamic obj) {
    return super == obj;
  }

  static String _getFamilyHash(Bits all, Bits one, Bits exclude) {
    StringBuffer stringBuilder = StringBuffer();
    if (!all.isEmpty) {
      stringBuilder..write("{all:")..write(_getBitsString(all))..write("}");
    }
    if (!one.isEmpty) {
      stringBuilder..write("{one:")..write(_getBitsString(one))..write("}");
    }
    if (!exclude.isEmpty) {
      stringBuilder
        ..write("{exclude:")
        ..write(_getBitsString(exclude))
        ..write("}");
    }
    return stringBuilder.toString();
  }

  static String _getBitsString(Bits bits) {
    StringBuffer stringBuilder = StringBuffer();

    int numBits = bits.length;
    for (int i = 0; i < numBits; ++i) {
      stringBuilder.write(bits[i] ? "1" : "0");
    }

    return stringBuilder.toString();
  }
}
