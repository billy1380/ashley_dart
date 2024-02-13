import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/utils/pool.dart';

abstract class BooleanInformer {
  bool get value;
}

class ComponentOperationPool extends Pool<ComponentOperation> {
  @override
  ComponentOperation newObject() {
    return ComponentOperation();
  }
}

enum ComponentOperationType {
  add,
  remove,
}

class ComponentOperation implements Poolable {
  ComponentOperationType? type;
  Entity? entity;

  void makeAdd(Entity entity) {
    type = ComponentOperationType.add;
    this.entity = entity;
  }

  void makeRemove(Entity entity) {
    type = ComponentOperationType.remove;
    this.entity = entity;
  }

  @override
  void reset() {
    entity = null;
  }
}

class ComponentOperationHandler {
  final BooleanInformer _delayed;
  final ComponentOperationPool _operationPool = ComponentOperationPool();
  final List<ComponentOperation> _operations = [];

  ComponentOperationHandler(this._delayed);

  void add(Entity entity) {
    if (_delayed.value) {
      ComponentOperation operation = _operationPool.obtain();
      operation.makeAdd(entity);
      _operations.add(operation);
    } else {
      entity.notifyComponentAdded();
    }
  }

  void remove(Entity entity) {
    if (_delayed.value) {
      ComponentOperation operation = _operationPool.obtain();
      operation.makeRemove(entity);
      _operations.add(operation);
    } else {
      entity.notifyComponentRemoved();
    }
  }

  bool get hasOperationsToProcess {
    return _operations.isNotEmpty;
  }

  void processOperations() {
    for (int i = 0; i < _operations.length; ++i) {
      ComponentOperation operation = _operations[i];

      switch (operation.type) {
        case ComponentOperationType.add:
          operation.entity!.notifyComponentAdded();
          break;
        case ComponentOperationType.remove:
          operation.entity!.notifyComponentRemoved();
          break;
        default:
          break;
      }

      _operationPool.free(operation);
    }

    _operations.clear();
  }
}
