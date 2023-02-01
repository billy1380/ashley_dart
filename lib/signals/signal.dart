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

import 'package:ashley_dart/signals/listener.dart';

/**
 * A Signal is a basic event class that can dispatch an event to multiple listeners. It uses generics to allow any type of object
 * to be passed around on dispatch.
 * @author Stefan Bachmann
 */
class Signal<T> {
  late List<Listener<T>?> _listeners;

  Signal() {
    _listeners = [];
  }

  /**
	 * Add a Listener to this Signal
	 * @param listener The Listener to be added
	 */
  void add(Listener<T>? listener) {
    _listeners.add(listener);
  }

  /**
	 * Remove a listener from this Signal
	 * @param listener The Listener to remove
	 */
  void remove(Listener<T>? listener) {
    _listeners.remove(listener);
  }

  /** Removes all listeners attached to this {@link Signal}. */
  void removeAllListeners() {
    _listeners.clear();
  }

  /**
	 * Dispatches an event to all Listeners registered to this Signal
	 * @param object The object to send off
	 */
  void dispatch(T object) {
    final List items = List.from(_listeners);
    for (int i = 0, n = _listeners.length; i < n; i++) {
      Listener<T> listener = items[i] as Listener<T>;
      listener.receive(this, object);
    }
  }
}
