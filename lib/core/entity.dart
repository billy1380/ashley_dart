import 'package:ashley_dart/core/component.dart';
import 'package:ashley_dart/core/component_operation_handler.dart';
import 'package:ashley_dart/core/component_type.dart';
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

import 'package:ashley_dart/signals/signal.dart';
import 'package:ashley_dart/utils/bag.dart';
import 'package:ashley_dart/utils/bits.dart';
import 'package:ashley_dart/utils/unmodifiable_list.dart';

/**
 * Simple containers of {@link Component}s that give them "data". The component's data is then processed by {@link EntitySystem}s.
 * @author Stefan Bachmann
 */
class Entity {
  /** A flag that can be used to bit mask this entity. Up to the user to manage. */
  int flags;
  /** Will dispatch an event when a component is added. */
  final Signal<Entity> componentAdded;
  /** Will dispatch an event when a component is removed. */
  final Signal<Entity> componentRemoved;

  bool scheduledForRemoval = false;
  bool removing = false;
  ComponentOperationHandler componentOperationHandler;

  Bag<Component> _components;
  List<Component> _componentsArray;
  List<Component> _immutableComponentsArray;
  Bits _componentBits;
  Bits _familyBits;

  /** Creates an empty Entity. */
  Entity()
      : componentAdded = Signal<Entity>(),
        componentRemoved = Signal<Entity>() {
    _components = Bag<Component>();
    _componentsArray = List();
    _immutableComponentsArray = unmodifiable(_componentsArray);
    _componentBits = Bits();
    _familyBits = Bits();
    flags = 0;
  }

  /**
	 * Adds a {@link Component} to this Entity. If a {@link Component} of the same type already exists, it'll be replaced.
	 * @return The Entity for easy chaining
	 */
  Entity add(Component component) {
    if (addInternal(component)) {
      if (componentOperationHandler != null) {
        componentOperationHandler.add(this);
      } else {
        notifyComponentAdded();
      }
    }

    return this;
  }

  /**
	 * Adds a {@link Component} to this Entity. If a {@link Component} of the same type already exists, it'll be replaced.
	 * @return The Component for direct component manipulation (e.g. PooledComponent)
	 */
  Component addAndReturn(Component component) {
    add(component);
    return component;
  }

  /**
	 * Removes the {@link Component} of the specified type. Since there is only ever one component of one type, we don't need an
	 * instance reference.
	 * @return The removed {@link Component}, or null if the Entity did no contain such a component.
	 */
  Component remove(Type componentClass) {
    ComponentType componentType = ComponentType.getFor(componentClass);
    int componentTypeIndex = componentType.index;

    if (_components.length > componentTypeIndex) {
      Component removeComponent = _components[componentTypeIndex];

      if (removeComponent != null && removeInternal(componentClass) != null) {
        if (componentOperationHandler != null) {
          componentOperationHandler.remove(this);
        } else {
          notifyComponentRemoved();
        }
      }

      return removeComponent;
    }

    return null;
  }

  /** Removes all the {@link Component}'s from the Entity. */
  void removeAll() {
    while (_componentsArray.length > 0) {
      remove(_componentsArray.last.runtimeType);
    }
  }

  /** @return immutable collection with all the Entity {@link Component}s. */
  List<Component> get components {
    return _immutableComponentsArray;
  }

  /**
	 * Retrieve a component from this {@link Entity} by class. <em>Note:</em> the preferred way of retrieving {@link Component}s is
	 * using {@link ComponentMapper}s. This method is provided for convenience; using a ComponentMapper provides O(1) access to
	 * components while this method provides only O(logn).
	 * @param componentClass the class of the component to be retrieved.
	 * @return the instance of the specified {@link Component} attached to this {@link Entity}, or null if no such
	 *         {@link Component} exists.
	 */
  T getComponent<T extends Component>(Type componentClass) {
    return this[ComponentType.getFor(componentClass)] as T;
  }

  /**
	 * Internal use.
	 * @return The {@link Component} object for the specified class, null if the Entity does not have any components for that class.
	 */
  Component operator [](ComponentType componentType) {
    int componentTypeIndex = componentType.index;

    if (componentTypeIndex < _components.length) {
      return _components[componentType.index];
    } else {
      return null;
    }
  }

  /**
	 * @return Whether or not the Entity has a {@link Component} for the specified class.
	 */
  bool hasComponent(ComponentType componentType) {
    return _componentBits[componentType.index];
  }

  /**
	 * @return This Entity's component bits, describing all the {@link Component}s it contains.
	 */
  Bits get componentBits {
    return _componentBits;
  }

  /** @return This Entity's {@link Family} bits, describing all the {@link EntitySystem}s it currently is being processed by. */
  Bits get familyBits {
    return _familyBits;
  }

  /**
	 * @param component
	 * @return whether or not the component was added.
	 */
  bool addInternal(Component component) {
    Type componentClass = component.runtimeType;
    Component oldComponent = getComponent(componentClass);

    if (component == oldComponent) {
      return false;
    }

    if (oldComponent != null) {
      removeInternal(componentClass);
    }

    int componentTypeIndex = ComponentType.getIndexFor(componentClass);
    _components[componentTypeIndex] = component;
    _componentsArray.add(component);
    _componentBits.set(componentTypeIndex);

    return true;
  }

  /**
	 * @param componentClass
	 * @return the component if the specified class was found and removed. Otherwise, null
	 */
  Component removeInternal(Type componentClass) {
    ComponentType componentType = ComponentType.getFor(componentClass);
    int componentTypeIndex = componentType.index;
    Component removeComponent = _components[componentTypeIndex];

    if (removeComponent != null) {
      _components[componentTypeIndex] = null;
      _componentsArray.remove(removeComponent);
      _componentBits.clear(componentTypeIndex);

      return removeComponent;
    }

    return null;
  }

  void notifyComponentAdded() {
    componentAdded.dispatch(this);
  }

  void notifyComponentRemoved() {
    componentRemoved.dispatch(this);
  }

  /** @return true if the entity is scheduled to be removed */
  bool isScheduledForRemoval() {
    return scheduledForRemoval;
  }
}
