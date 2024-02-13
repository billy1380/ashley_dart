import 'dart:collection';

import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/core/entity_listener.dart';
import 'package:ashley_dart/core/family.dart';
import 'package:ashley_dart/utils/bits.dart';
import 'package:ashley_dart/utils/pool.dart';

class _EntityListenerData {
  EntityListener? _listener;
  late int _priority;
}

class _BitsPool extends Pool<Bits> {
  @override
  Bits newObject() {
    return Bits();
  }
}

class FamilyManager {
  List<Entity?>? entities;
  final Map<Family, List<Entity?>> _families = {};
  final Map<Family, List<Entity?>> _immutableFamilies = {};
  final List<_EntityListenerData> _entityListeners = [];
  final Map<Family, Bits> _entityListenerMasks = {};
  final _BitsPool _bitsPool = _BitsPool();
  bool _notifying = false;

  FamilyManager(this.entities);

  List<Entity?> operator [](Family family) {
    return _registerFamily(family);
  }

  bool get notifying {
    return _notifying;
  }

  void addEntityListener(
      Family family, int priority, EntityListener? listener) {
    _registerFamily(family);

    int insertionIndex = 0;
    while (insertionIndex < _entityListeners.length) {
      if (_entityListeners[insertionIndex]._priority <= priority) {
        insertionIndex++;
      } else {
        break;
      }
    }

    // Shift up bitmasks by one step
    for (Bits mask in _entityListenerMasks.values) {
      for (int k = mask.length; k > insertionIndex; k--) {
        if (mask[k - 1]) {
          mask.set(k);
        } else {
          mask.clear(k);
        }
      }
      mask.clear(insertionIndex);
    }

    _entityListenerMasks[family]!.set(insertionIndex);

    _EntityListenerData entityListenerData = _EntityListenerData();
    entityListenerData._listener = listener;
    entityListenerData._priority = priority;
    _entityListeners.insert(insertionIndex, entityListenerData);
  }

  void removeEntityListener(EntityListener listener) {
    for (int i = 0; i < _entityListeners.length; i++) {
      _EntityListenerData entityListenerData = _entityListeners[i];
      if (entityListenerData._listener == listener) {
        // Shift down bitmasks by one step
        for (Bits mask in _entityListenerMasks.values) {
          for (int k = i, n = mask.length; k < n; k++) {
            if (mask[k + 1]) {
              mask.set(k);
            } else {
              mask.clear(k);
            }
          }
        }

        _entityListeners.removeAt(i--);
      }
    }
  }

  void updateFamilyMembership(Entity? entity) {
    // Find families that the entity was added to/removed from, and fill
    // the bitmasks with corresponding listener bits.
    Bits addListenerBits = _bitsPool.obtain();
    Bits removeListenerBits = _bitsPool.obtain();

    for (Family family in _entityListenerMasks.keys) {
      final int familyIndex = family.index;
      final Bits entityFamilyBits = entity!.familyBits!;

      bool belongsToFamily = entityFamilyBits[familyIndex];
      bool matches = family.matches(entity) && !entity.removing;

      if (belongsToFamily != matches) {
        final Bits? listenersMask = _entityListenerMasks[family];
        final List<Entity?>? familyEntities = _families[family];
        if (matches) {
          addListenerBits.or(listenersMask!);
          familyEntities!.add(entity);
          entityFamilyBits.set(familyIndex);
        } else {
          removeListenerBits.or(listenersMask!);
          familyEntities!.remove(entity);
          entityFamilyBits.clear(familyIndex);
        }
      }
    }

    // Notify listeners; set bits match indices of listeners
    _notifying = true;
    List items = List.from(_entityListeners);

    try {
      for (int i = removeListenerBits.nextSetBit(0);
          i >= 0;
          i = removeListenerBits.nextSetBit(i + 1)) {
        (items[i] as _EntityListenerData)._listener!.entityRemoved(entity);
      }

      for (int i = addListenerBits.nextSetBit(0);
          i >= 0;
          i = addListenerBits.nextSetBit(i + 1)) {
        (items[i] as _EntityListenerData)._listener!.entityAdded(entity);
      }
    } finally {
      addListenerBits.clear();
      removeListenerBits.clear();
      _bitsPool.free(addListenerBits);
      _bitsPool.free(removeListenerBits);
      _notifying = false;
    }
  }

  List<Entity?> _registerFamily(Family family) {
    List<Entity?>? entitiesInFamily = _immutableFamilies[family];

    if (entitiesInFamily == null) {
      List<Entity?> familyEntities = [];
      entitiesInFamily = UnmodifiableListView(familyEntities);
      _families[family] = familyEntities;
      _immutableFamilies[family] = entitiesInFamily;
      _entityListenerMasks[family] = Bits();

      for (Entity? entity in entities!) {
        updateFamilyMembership(entity);
      }
    }

    return UnmodifiableListView(entitiesInFamily);
  }
}
