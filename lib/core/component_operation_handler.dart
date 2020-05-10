import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/utils/pool.dart';

abstract class BooleanInformer {
  bool get value;
}

class ComponentOperationPool extends Pool<_ComponentOperation> {
  @override
  _ComponentOperation newObject() {
    return _ComponentOperation();
  }
}

enum ComponentOperationType {
  Add,
  Remove,
}

class _ComponentOperation implements Poolable {
  ComponentOperationType type;
  Entity entity;

  void makeAdd(Entity entity) {
    this.type = ComponentOperationType.Add;
    this.entity = entity;
  }

  void makeRemove(Entity entity) {
    this.type = ComponentOperationType.Remove;
    this.entity = entity;
  }

  @override
  void reset() {
    entity = null;
  }
}

class ComponentOperationHandler {
  BooleanInformer _delayed;
  ComponentOperationPool _operationPool = ComponentOperationPool();
  List<_ComponentOperation> _operations = [];

  ComponentOperationHandler(this._delayed);

  void add(Entity entity) {
    if (_delayed.value) {
      _ComponentOperation operation = _operationPool.obtain();
      operation.makeAdd(entity);
      _operations.add(operation);
    } else {
      entity.notifyComponentAdded();
    }
  }

  void remove(Entity entity) {
    if (_delayed.value) {
      _ComponentOperation operation = _operationPool.obtain();
      operation.makeRemove(entity);
      _operations.add(operation);
    } else {
      entity.notifyComponentRemoved();
    }
  }

  bool get hasOperationsToProcess {
    return _operations.length > 0;
  }

  void processOperations() {
    for (int i = 0; i < _operations.length; ++i) {
      _ComponentOperation operation = _operations[i];

      switch (operation.type) {
        case ComponentOperationType.Add:
          operation.entity.notifyComponentAdded();
          break;
        case ComponentOperationType.Remove:
          operation.entity.notifyComponentRemoved();
          break;
        default:
          break;
      }

      _operationPool.free(operation);
    }

    _operations.clear();
  }
}
