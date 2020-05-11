import 'package:ashley_dart/core/component.dart';
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

import 'package:ashley_dart/core/component_operation_handler.dart';
import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/core/entity_listener.dart';
import 'package:ashley_dart/core/entity_manager.dart';
import 'package:ashley_dart/core/entity_system.dart';
import 'package:ashley_dart/core/family.dart';
import 'package:ashley_dart/core/family_manager.dart';
import 'package:ashley_dart/core/system_manager.dart';
import 'package:ashley_dart/signals/listener.dart';
import 'package:ashley_dart/signals/signal.dart';
import 'package:ashley_dart/utils/constructor_pool.dart';

class _ComponentListener implements Listener<Entity> {
  final FamilyManager _familyManager;

  const _ComponentListener(this._familyManager);

  @override
  void receive(Signal<Entity> signal, Entity object) {
    _familyManager.updateFamilyMembership(object);
  }
}

class _EngineSystemListener implements SystemListener {
  final Engine _engine;

  const _EngineSystemListener(this._engine);

  @override
  void systemAdded(EntitySystem system) {
    system.addedToEngineInternal(_engine);
  }

  @override
  void systemRemoved(EntitySystem system) {
    system.removedFromEngineInternal(_engine);
  }
}

class _EngineEntityListener implements EntityListener {
  final Engine _engine;

  const _EngineEntityListener(this._engine);

  @override
  void entityAdded(Entity entity) {
    _engine.addEntityInternal(entity);
  }

  @override
  void entityRemoved(Entity entity) {
    _engine.removeEntityInternal(entity);
  }
}

class _EngineDelayedInformer implements BooleanInformer {
  final Engine _engine;

  const _EngineDelayedInformer(this._engine);

  @override
  bool get value {
    return _engine._updating;
  }
}

/**
 * The heart of the Entity framework. It is responsible for keeping track of {@link Entity} and
 * managing {@link EntitySystem} objects. The Engine should be updated every tick via the {@link #update(float)} method.
 *
 * With the Engine you can:
 *
 * <ul>
 * <li>Add/Remove {@link Entity} objects</li>
 * <li>Add/Remove {@link EntitySystem}s</li>
 * <li>Obtain a list of entities for a specific {@link Family}</li>
 * <li>Update the main loop</li>
 * <li>Register/unregister {@link EntityListener} objects</li>
 * </ul>
 *
 * @author Stefan Bachmann
 * 
 * Dart version notes:
 * To create components using the engine component constructors must be registered against their types
 */
class Engine {
  static Family _empty = Family.all([]).get();

  final Map<Type, Constructor> constructors = {};

  Listener<Entity> _componentAdded;
  Listener<Entity> _componentRemoved;

  SystemManager _systemManager;
  EntityManager _entityManager;
  ComponentOperationHandler _componentOperationHandler;
  FamilyManager _familyManager;
  bool _updating = false;

  Engine() {
    _entityManager = EntityManager(_EngineEntityListener(this));
    _familyManager = FamilyManager(_entityManager.entities);
    _componentAdded = _ComponentListener(_familyManager);
    _componentRemoved = _ComponentListener(_familyManager);
    _systemManager = SystemManager(_EngineSystemListener(this));
    _componentOperationHandler =
        ComponentOperationHandler(_EngineDelayedInformer(this));
  }

  /** 
   * Adds a constructor for a type (used in lieu of reflection)
   */
  void registerType<T>(Type type, Constructor<T> constructor) {
    constructors[type] = constructor;
  }

  /**
	 * Creates a new Entity object.
	 * @return @{@link Entity}
	 */
  Entity createEntity() {
    return new Entity();
  }

  /**
	 * Creates a new {@link Component}. To use that method your components must have a visible no-arg constructor
	 */
  T createComponent<T extends Component>(Type componentType) {
    return constructors[componentType]();
  }

  /**
	 * Adds an entity to this Engine.
	 * This will throw an IllegalArgumentException if the given entity
	 * was already registered with an engine.
	 */
  void addEntity(Entity entity) {
    bool delayed = _updating || _familyManager.notifying;
    _entityManager.addEntity(entity, delayed);
  }

  /**
	 * Removes an entity from this Engine.
	 */
  void removeEntity(Entity entity) {
    bool delayed = _updating || _familyManager.notifying;
    _entityManager.removeEntity(entity, delayed);
  }

  /**
	 * Removes all entities of the given {@link Family}.
	 */
  void removeAllEntities([Family family]) {
    if (family == null) {
      bool delayed = _updating || _familyManager.notifying;
      _entityManager.removeAllEntities(null, delayed);
    } else {
      bool delayed = _updating || _familyManager.notifying;
      _entityManager.removeAllEntities(this[family], delayed);
    }
  }

  /**
	 * Returns an {@link List} of {@link Entity} that is managed by the the Engine
	 *  but cannot be used to modify the state of the Engine. This List is not Immutable in
	 *  the sense that its contents will not be modified, but in the sense that it only reflects
	 *  the state of the engine.
	 *
	 * The List is Immutable in the sense that you cannot modify its contents through the API of
	 *  the {@link List} class, but is instead "Managed" by the Engine itself. The engine
	 *  may add or remove items from the array and this will be reflected in the returned array.
	 *
	 * This is an important note if you are looping through the returned entities and calling operations
	 *  that may add/remove entities from the engine, as the underlying iterator of the returned array
	 *  will reflect these modifications.
	 *
	 * The returned array will have entities removed from it if they are removed from the engine,
	 *   but there is no way to introduce new Entities through the array's interface, or remove
	 *   entities from the engine through the array interface.
	 *
	 *  Discussion of this can be found at https://github.com/libgdx/ashley/issues/224
	 *
	 * @return An unmodifiable array of entities that will match the state of the entities in the
	 *  engine.
	 */
  List<Entity> get entities {
    return _entityManager.entities;
  }

  /**
	 * Adds the {@link EntitySystem} to this Engine.
	 * If the Engine already had a system of the same class,
	 * the new one will replace the old one.
	 */
  void addSystem(EntitySystem system) {
    _systemManager.addSystem(system);
  }

  /**
	 * Removes the {@link EntitySystem} from this Engine.
	 */
  void removeSystem(EntitySystem system) {
    _systemManager.removeSystem(system);
  }

  /**
	 * Removes all systems from this Engine.
	 */
  void removeAllSystems() {
    _systemManager.removeAllSystems();
  }

  /**
	 * Quick {@link EntitySystem} retrieval.
	 */

  T getSystem<T extends EntitySystem>(Type systemType) {
    return _systemManager.getSystem(systemType);
  }

  /**
	 * @return immutable array of all entity systems managed by the {@link Engine}.
	 */
  List<EntitySystem> getSystems() {
    return _systemManager.getSystems();
  }

  /**
	 * Returns immutable collection of entities for the specified {@link Family}. Will return the same instance every time.
	 */
  List<Entity> operator [](Family family) {
    return _familyManager[family];
  }

  /**
	 * Adds an {@link EntityListener} for a specific {@link Family}. The listener will be notified every time an entity is
	 * added/removed to/from the given family. The priority determines in which order the entity listeners will be called. Lower
	 * value means it will get executed first.
	 */
  void addEntityListener(
      [Family family, int priority = 0, EntityListener listener]) {
    _familyManager.addEntityListener(
        family ?? Engine._empty, priority, listener);
  }

  /**
	 * Removes an {@link EntityListener}
	 */
  void removeEntityListener(EntityListener listener) {
    _familyManager.removeEntityListener(listener);
  }

  /**
	 * Updates all the systems in this Engine.
	 * @param deltaTime The time passed since the last frame.
	 */
  void update(double deltaTime) {
    if (_updating) {
      throw Exception(
          "Cannot call update() on an Engine that is already updating.");
    }

    _updating = true;
    List<EntitySystem> systems = _systemManager.getSystems();
    try {
      for (int i = 0; i < systems.length; ++i) {
        EntitySystem system = systems[i];

        if (system.processing) {
          system.update(deltaTime);
        }

        while (_componentOperationHandler.hasOperationsToProcess ||
            _entityManager.hasPendingOperations) {
          _componentOperationHandler.processOperations();
          _entityManager.processPendingOperations();
        }
      }
    } finally {
      _updating = false;
    }
  }

  void addEntityInternal(Entity entity) {
    entity.componentAdded.add(_componentAdded);
    entity.componentRemoved.add(_componentRemoved);
    entity.componentOperationHandler = _componentOperationHandler;

    _familyManager.updateFamilyMembership(entity);
  }

  void removeEntityInternal(Entity entity) {
    _familyManager.updateFamilyMembership(entity);

    entity.componentAdded.remove(_componentAdded);
    entity.componentRemoved.remove(_componentRemoved);
    entity.componentOperationHandler = null;
  }
}
