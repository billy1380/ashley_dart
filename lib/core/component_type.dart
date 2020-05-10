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

/**
 * Uniquely identifies a {@link Component} sub-class. It assigns them an index which is used internally for fast comparison and
 * retrieval. See {@link Family} and {@link Entity}. ComponentType is a package protected class. You cannot instantiate a
 * ComponentType. They can only be accessed via {@link #getIndexFor(Class<? extends Component>)}. Each component class will always
 * return the same instance of ComponentType.
 * @author Stefan Bachmann
 */
class ComponentType {
  static Map<Type, ComponentType> assignedComponentTypes = {};
  static int _typeIndex = 0;

  final int _index;

  ComponentType._() : _index = _typeIndex++;

  /** @return This ComponentType's unique index */
  int get index {
    return _index;
  }

  /**
	 * @param componentType The {@link Component} class
	 * @return A ComponentType matching the Component Class
	 */
  static ComponentType getFor(Type componentType) {
    ComponentType type = assignedComponentTypes[componentType];

    if (type == null) {
      type = ComponentType._();
      assignedComponentTypes[componentType] = type;
    }

    return type;
  }

  /**
	 * Quick helper method. The same could be done via {@link ComponentType.getFor(Class<? extends Component>)}.
	 * @param componentType The {@link Component} class
	 * @return The index for the specified {@link Component} Class
	 */
  static int getIndexFor(Type componentType) {
    return getFor(componentType).index;
  }

  /**
	 * @param componentTypes list of {@link Component} classes
	 * @return Bits representing the collection of components for quick comparison and matching. See
	 *         {@link Family#getFor(Bits, Bits, Bits)}.
	 */
  static Bits getBitsFor(List<Type> componentTypes) {
    Bits bits = Bits();

    int typesLength = componentTypes.length;
    for (int i = 0; i < typesLength; i++) {
      bits.set(ComponentType.getIndexFor(componentTypes[i]));
    }

    return bits;
  }

  @override
  int get hashCode {
    return index;
  }

  @override
  bool operator ==(dynamic obj) {
    if (super == obj) return true;
    if (obj == null) return false;
    if (runtimeType != obj.runtimeType) return false;
    ComponentType other = obj as ComponentType;
    return index == other.index;
  }
}
