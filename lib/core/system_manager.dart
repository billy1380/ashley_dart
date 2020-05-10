import 'package:ashley_dart/core/entity_system.dart';
import 'package:ashley_dart/utils/unmodifiable_list.dart';

typedef _SystemComparator = int Function(EntitySystem a, EntitySystem b);

abstract class SystemListener {
  void systemAdded(EntitySystem system);
  void systemRemoved(EntitySystem system);
}

class SystemManager {
  _SystemComparator _systemComparator = (EntitySystem a, EntitySystem b) {
    return a.priority > b.priority ? 1 : (a.priority == b.priority) ? 0 : -1;
  };
  List<EntitySystem> _systems = [];
  List<EntitySystem> _immutableSystems;
  Map<Type, EntitySystem> _systemsByClass = {};
  SystemListener _listener;

  SystemManager(this._listener) {
    _immutableSystems = unmodifiable(_systems);
  }

  void addSystem(EntitySystem system) {
    Type systemType = system.runtimeType;
    EntitySystem oldSytem = getSystem(systemType);

    if (oldSytem != null) {
      removeSystem(oldSytem);
    }

    _systems.add(system);
    _systemsByClass[systemType] = system;
    _systems.sort(_systemComparator);
    _listener.systemAdded(system);
  }

  void removeSystem(EntitySystem system) {
    if (_systems.remove(system)) {
      _systemsByClass.remove(system.runtimeType);
      _listener.systemRemoved(system);
    }
  }

  void removeAllSystems() {
    while (_systems.length > 0) {
      removeSystem(_systems.first);
    }
  }

  T getSystem<T extends EntitySystem>(Type systemType) {
    return _systemsByClass[systemType] as T;
  }

  List<EntitySystem> getSystems() {
    return _immutableSystems;
  }
}
