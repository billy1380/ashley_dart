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
import 'package:ashley_dart/core/family.dart';
import 'package:ashley_dart/systems/interval_system.dart';

/// A simple {@link EntitySystem} that processes a {@link Family} of entities not once per frame, but after a given interval.
/// Entity processing logic should be placed in {@link IntervalIteratingSystem#processEntity(Entity)}.
/// @author David Saltares
abstract class IntervalIteratingSystem extends IntervalSystem {
  final Family _family;
  List<Entity?>? _entities;

  /// @param family represents the collection of family the system should process
  /// @param interval time in seconds between calls to {@link IntervalIteratingSystem#updateInterval()}.
  /// @param priority
  IntervalIteratingSystem(this._family, double interval, [int priority = 0])
      : super(interval, priority);

  @override
  void addedToEngine(Engine? engine) {
    _entities = engine![_family];
  }

  @override
  void updateInterval() {
    for (int i = 0; i < _entities!.length; ++i) {
      processEntity(_entities![i]);
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

  /// The user should place the entity processing logic here.
  /// @param entity
  void processEntity(Entity? entity);
}
