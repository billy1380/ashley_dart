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

/**
 * A simple {@link EntitySystem} that does not run its update logic every call to {@link EntitySystem#update(float)}, but after a
 * given interval. The actual logic should be placed in {@link IntervalSystem#updateInterval()}.
 * @author David Saltares
 */
abstract class IntervalSystem extends EntitySystem {
  double _interval;
  double _accumulator = 0;

  /**
	 * @param interval time in seconds between calls to {@link IntervalSystem#updateInterval()}.
	 * @param priority
	 */
  IntervalSystem(this._interval, [int priority = 0]) : super(priority);

  double get interval => _interval;

  @override
  void update(double deltaTime) {
    _accumulator += deltaTime;

    while (_accumulator >= _interval) {
      _accumulator -= _interval;
      updateInterval();
    }
  }

  /**
	 * The processing logic of the system should be placed here.
	 */
  void updateInterval();
}
