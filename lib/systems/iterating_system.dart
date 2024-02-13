/// *****************************************************************************
/// Copyright 2014 See AUTHORS file.
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///****************************************************************************
library;

import 'package:ashley_dart/core/engine.dart';
import 'package:ashley_dart/core/entity.dart';
import 'package:ashley_dart/core/entity_system.dart';
import 'package:ashley_dart/core/family.dart';

/// A simple EntitySystem that iterates over each entity and calls processEntity() for each entity every time the EntitySystem is
/// updated. This is really just a convenience class as most systems iterate over a list of entities.
/// @author Stefan Bachmann
abstract class IteratingSystem extends EntitySystem {
  final Family _family;
  List<Entity?>? _entities;

  /// Instantiates a system that will iterate over the entities described by the Family, with a specific priority.
  /// @param family The family of entities iterated over in this System
  /// @param priority The priority to execute this system with (lower means higher priority)
  IteratingSystem(this._family, [int priority = 0]) : super(priority);

  @override
  void addedToEngine(Engine? engine) {
    _entities = engine![_family];
  }

  @override
  void removedFromEngine(Engine? engine) {
    _entities = null;
  }

  @override
  void update(double deltaTime) {
    for (int i = 0; i < _entities!.length; ++i) {
      processEntity(_entities![i], deltaTime);
    }
  }

  /// @return set of entities processed by the system
  List<Entity?>? get entities {
    return _entities;
  }

  /// @return the Family used when the system was created
  Family get family {
    return _family;
  }

  /// This method is called on every entity on every update call of the EntitySystem. Override this to implement your system's
  /// specific processing.
  /// @param entity The current Entity being processed
  /// @param deltaTime The delta time between the last and current frame
  void processEntity(Entity? entity, double deltaTime);
}
