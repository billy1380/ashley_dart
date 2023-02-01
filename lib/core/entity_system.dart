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

import 'package:ashley_dart/core/engine.dart';

/**
 * Abstract class for processing sets of {@link Entity} objects.
 * @author Stefan Bachmann
 */
abstract class EntitySystem {
  /** Use this to set the priority of the system. Lower means it'll get executed first. */
  int priority;

  bool? _processing;
  Engine? _engine;

  /**
	 * Initialises the EntitySystem with the priority specified.
	 * @param priority The priority to execute this system with (lower means higher priority).
	 */
  EntitySystem([this.priority = 0]) {
    this._processing = true;
  }

  /**
	 * Called when this EntitySystem is added to an {@link Engine}.
	 * @param engine The {@link Engine} this system was added to.
	 */
  void addedToEngine(Engine? engine) {}

  /**
	 * Called when this EntitySystem is removed from an {@link Engine}.
	 * @param engine The {@link Engine} the system was removed from.
	 */
  void removedFromEngine(Engine? engine) {}

  /**
	 * The update method called every tick.
	 * @param deltaTime The time passed since last frame in seconds.
	 */
  void update(double deltaTime) {}

  /** @return Whether or not the system should be processed. */
  bool? get processing {
    return _processing;
  }

  /** Sets whether or not the system should be processed by the {@link Engine}. */
  set processing(bool? value) {
    this._processing = value;
  }

  /** @return engine instance the system is registered to.
	 * It will be null if the system is not associated to any engine instance. */
  Engine? get engine {
    return _engine;
  }

  void addedToEngineInternal(Engine engine) {
    this._engine = engine;
    addedToEngine(engine);
  }

  void removedFromEngineInternal(Engine engine) {
    this._engine = null;
    removedFromEngine(engine);
  }
}
