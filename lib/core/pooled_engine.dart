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

import 'package:ashley_dart/ashley_dart.dart';
import 'package:ashley_dart/utils/constructor_pool.dart';

class PooledEntity extends Entity implements Poolable {
  final ComponentPools? _componentPools;

  PooledEntity(this._componentPools);

  @override
  Component? removeInternal(Type componentClass) {
    Component? removed = super.removeInternal(componentClass);
    if (removed != null) {
      _componentPools!.free(removed);
    }

    return removed;
  }

  @override
  void reset() {
    removeAll();
    flags = 0;
    componentAdded.removeAllListeners();
    componentRemoved.removeAllListeners();
    scheduledForRemoval = false;
    removing = false;
  }
}

class EntityPool extends Pool<PooledEntity> {
  final ComponentPools? _componentPools;
  EntityPool(this._componentPools, int initialSize, int maxSize)
      : super(initialSize, maxSize);

  @override
  PooledEntity newObject() {
    return PooledEntity(_componentPools);
  }
}

class ComponentPools {
  Map<Type, ConstructorPool> _pools = {};
  final Map<Type, Constructor> _constructors;
  int _initialSize;
  int _maxSize;

  ComponentPools(this._constructors, this._initialSize, this._maxSize);

  T? obtain<T>(Type type) {
    ConstructorPool? pool = _pools[type];

    if (pool == null) {
      pool = ConstructorPool(type, _constructors[type], _initialSize, _maxSize);
      _pools[type] = pool;
    }

    return pool.obtain() as T?;
  }

  void free(Object object) {
    ConstructorPool? pool = _pools[object.runtimeType];

    if (pool == null) {
      return; // Ignore freeing an object that was never retained.
    }

    pool.free(object);
  }

  void freeAll(List objects) {
    for (int i = 0, n = objects.length; i < n; i++) {
      Object object = objects[i];
      free(object);
    }
  }

  void clear() {
    for (Pool pool in _pools.values) {
      pool.clear();
    }
  }
}

/**
 * Supports {@link Entity} and {@link Component} pooling. This improves performance in environments where creating/deleting
 * entities is frequent as it greatly reduces memory allocation.
 * <ul>
 * <li>Create entities using {@link #createEntity()}</li>
 * <li>Create components using {@link #createComponent(Class)}</li>
 * <li>Components should implement the {@link Poolable} interface when in need to reset its state upon removal</li>
 * </ul>
 * @author David Saltares
 */
class PooledEngine extends Engine {
  late EntityPool _entityPool;
  ComponentPools? _componentPools;

  /**
	 * Creates PooledEngine with the specified pools size configurations.
	 * @param entityPoolInitialSize initial number of pre-allocated entities.
	 * @param entityPoolMaxSize maximum number of pooled entities.
	 * @param componentPoolInitialSize initial size for each component type pool.
	 * @param componentPoolMaxSize maximum size for each component type pool.
	 */
  PooledEngine(
      [int entityPoolInitialSize = 10,
      int entityPoolMaxSize = 100,
      int componentPoolInitialSize = 10,
      int componentPoolMaxSize = 100])
      : super() {
    _entityPool =
        EntityPool(_componentPools, entityPoolInitialSize, entityPoolMaxSize);
    _componentPools = ComponentPools(
        constructors, componentPoolInitialSize, componentPoolMaxSize);
  }

  /** @return Clean {@link Entity} from the Engine pool. In order to add it to the {@link Engine}, use {@link #addEntity(Entity)}. @{@link Override {@link Engine#createEntity()}} */
  @override
  Entity createEntity() {
    return _entityPool.obtain();
  }

  /**
	 * Retrieves a {@link Component} from the {@link Engine} pool. It will be placed back in the pool whenever it's removed
	 * from an {@link Entity} or the {@link Entity} itself it's removed.
	 * Overrides the default implementation of Engine (creating a Object)
	 */
  @override
  T? createComponent<T extends Component>(Type componentType) {
    return _componentPools!.obtain<T>(componentType);
  }

  /**
	 * Removes all free entities and components from their pools. Although this will likely result in garbage collection, it will
	 * free up memory.
	 */
  void clearPools() {
    _entityPool.clear();
    _componentPools!.clear();
  }

  @override
  void removeEntityInternal(Entity entity) {
    super.removeEntityInternal(entity);

    if (entity is PooledEntity) {
      _entityPool.free(entity);
    }
  }
}
