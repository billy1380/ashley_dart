import 'dart:collection';

import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/core/entity_listener.dart';
import 'package:ashley_dart/utils/pool.dart';

enum EntityOperationType {
  Add,
  Remove,
  RemoveAll,
}

class _EntityOperation implements Poolable {
  EntityOperationType? type;
  Entity? entity;
  late List<Entity?> entities;

  @override
  void reset() {
    entity = null;
  }
}

class _EntityOperationPool extends Pool<_EntityOperation> {
  @override
  _EntityOperation newObject() {
    return new _EntityOperation();
  }
}

class EntityManager {
  EntityListener _listener;
  List<Entity?> _entities = [];
  Set<Entity?> _entitySet = <Entity?>{};
  late List<Entity?> _immutableEntities;
  List<_EntityOperation> _pendingOperations = [];
  _EntityOperationPool _entityOperationPool = _EntityOperationPool();

  EntityManager(this._listener) {
    _immutableEntities = UnmodifiableListView(_entities);
  }

  void addEntity(Entity entity, [bool delayed = false]) {
    if (delayed) {
      _EntityOperation operation = _entityOperationPool.obtain();
      operation.entity = entity;
      operation.type = EntityOperationType.Add;
      _pendingOperations.add(operation);
    } else {
      addEntityInternal(entity);
    }
  }

  void removeEntity(Entity? entity, [bool delayed = false]) {
    if (delayed) {
      if (entity!.scheduledForRemoval) {
        return;
      }
      entity.scheduledForRemoval = true;
      _EntityOperation operation = _entityOperationPool.obtain();
      operation.entity = entity;
      operation.type = EntityOperationType.Remove;
      _pendingOperations.add(operation);
    } else {
      removeEntityInternal(entity);
    }
  }

  void removeAllEntities([List<Entity?>? entities, bool delayed = false]) {
    if (entities == null) {
      entities = _immutableEntities;
    }

    if (delayed) {
      for (Entity? entity in entities) {
        entity!.scheduledForRemoval = true;
      }
      _EntityOperation operation = _entityOperationPool.obtain();
      operation.type = EntityOperationType.RemoveAll;
      operation.entities = entities;
      _pendingOperations.add(operation);
    } else {
      while (entities.isNotEmpty) {
        removeEntity(entities.first, false);
      }
    }
  }

  List<Entity?>? get entities {
    return _immutableEntities;
  }

  bool get hasPendingOperations {
    return _pendingOperations.isNotEmpty;
  }

  void processPendingOperations() {
    for (int i = 0; i < _pendingOperations.length; ++i) {
      _EntityOperation operation = _pendingOperations[i];

      switch (operation.type) {
        case EntityOperationType.Add:
          addEntityInternal(operation.entity);
          break;
        case EntityOperationType.Remove:
          removeEntityInternal(operation.entity);
          break;
        case EntityOperationType.RemoveAll:
          while (operation.entities.isNotEmpty) {
            removeEntityInternal(operation.entities.first);
          }
          break;
        default:
          throw new AssertionError("Unexpected EntityOperation type");
      }

      _entityOperationPool.free(operation);
    }

    _pendingOperations.clear();
  }

  void removeEntityInternal(Entity? entity) {
    bool removed = _entitySet.remove(entity);

    if (removed) {
      entity!.scheduledForRemoval = false;
      entity.removing = true;
      _entities.remove(entity);
      _listener.entityRemoved(entity);
      entity.removing = false;
    }
  }

  void addEntityInternal(Entity? entity) {
    if (_entitySet.contains(entity)) {
      throw Exception("Entity is already registered $entity");
    }

    _entities.add(entity);
    _entitySet.add(entity);

    _listener.entityAdded(entity);
  }
}
