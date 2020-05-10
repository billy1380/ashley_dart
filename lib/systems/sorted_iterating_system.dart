import 'package:ashley_dart/core/engine.dart';
import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/core/entity_listener.dart';
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

import 'package:ashley_dart/core/entity_system.dart';
import 'package:ashley_dart/core/family.dart';
import 'package:ashley_dart/utils/unmodifiable_list.dart';

/**
 * A simple EntitySystem that processes each entity of a given family in the order specified by a comparator and calls
 * processEntity() for each entity every time the EntitySystem is updated. This is really just a convenience class as rendering
 * systems tend to iterate over a list of entities in a sorted manner. Adding entities will cause the entity list to be resorted.
 * Call forceSort() if you changed your sorting criteria.
 * @author Santo Pfingsten
 */
abstract class SortedIteratingSystem extends EntitySystem
    implements EntityListener {
  Family _family;
  List<Entity> _sortedEntities = [];
  List<Entity> _entities;
  bool _shouldSort;
  Comparator<Entity> _comparator;

  /**
	 * Instantiates a system that will iterate over the entities described by the Family, with a specific priority.
	 * @param family The family of entities iterated over in this System
	 * @param comparator The comparator to sort the entities
	 * @param priority The priority to execute this system with (lower means higher priority)
	 */
  SortedIteratingSystem(this._family, this._comparator, [int priority = 0])
      : super(priority) {
    _entities = unmodifiable(_sortedEntities);
  }

  /**
	 * Call this if the sorting criteria have changed. The actual sorting will be delayed until the entities are processed.
	 */
  void forceSort() {
    _shouldSort = true;
  }

  void _sort() {
    if (_shouldSort) {
      _sortedEntities.sort(_comparator);
      _shouldSort = false;
    }
  }

  @override
  void addedToEngine(Engine engine) {
    List<Entity> newEntities = engine[_family];
    _sortedEntities.clear();
    if (newEntities.length > 0) {
      for (int i = 0; i < newEntities.length; ++i) {
        _sortedEntities.add(newEntities[i]);
      }
      _sortedEntities.sort(_comparator);
    }
    _shouldSort = false;
    engine.addEntityListener(_family, 0, this);
  }

  @override
  void removedFromEngine(Engine engine) {
    engine.removeEntityListener(this);
    _sortedEntities.clear();
    _shouldSort = false;
  }

  @override
  void entityAdded(Entity entity) {
    _sortedEntities.add(entity);
    _shouldSort = true;
  }

  @override
  void entityRemoved(Entity entity) {
    _sortedEntities.remove(entity);
    _shouldSort = true;
  }

  @override
  void update(double deltaTime) {
    _sort();
    for (int i = 0; i < _sortedEntities.length; ++i) {
      processEntity(_sortedEntities[i], deltaTime);
    }
  }

  /**
	 * @return set of entities processed by the system
	 */
  List<Entity> get entities {
    _sort();
    return _entities;
  }

  /**
	 * @return the Family used when the system was created
	 */
  Family get family {
    return _family;
  }

  /**
	 * This method is called on every entity on every update call of the EntitySystem. Override this to implement your system's
	 * specific processing.
	 * @param entity The current Entity being processed
	 * @param deltaTime The delta time between the last and current frame
	 */
  void processEntity(Entity entity, double deltaTime);
}
