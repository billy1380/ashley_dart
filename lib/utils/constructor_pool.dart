/*******************************************************************************
 * Copyright 2011 See AUTHORS file.
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

import 'package:ashley_dart/ashley_dart.dart';

typedef Constructor<T> = T Function();

/** Pool that creates new instances of a type using a passed constructor method. The type must have a zero argument constructor.
 * {@link Constructor#setAccessible(boolean)} will be used if the class and/or constructor is not visible.
 * @author Nathan Sweet */
class ConstructorPool<T> extends Pool<T> {
  final Constructor _constructor;

  ConstructorPool(Type type, this._constructor,
      [int initialCapacity = 16, int max = INT_MAX, bool preFill = false])
      : super(initialCapacity, max, preFill) {
    if (_constructor == null)
      throw Exception(
          "Class cannot be created (missing no-arg constructor): ${type.runtimeType}");
  }

  T newObject() {
    try {
      return _constructor() as T;
    } on Exception catch (ex) {
      throw Exception(
          "Unable to create new instance $_constructor with cause $ex");
    }
  }
}
