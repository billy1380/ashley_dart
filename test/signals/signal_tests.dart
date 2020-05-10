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
import 'package:ashley_dart/ashley_dart.dart';
import 'package:test/test.dart';
import '../helpers.dart';

class Dummy {}

class ListenerMock implements Listener<Dummy> {
  int count = 0;

  @override
  void receive(Signal<Dummy> signal, Dummy object) {
    ++count;

    assertNotNull(signal);
    assertNotNull(object);
  }
}

class RemoveWhileDispatchListenerMock implements Listener<Dummy> {
  int count = 0;

  @override
  void receive(Signal<Dummy> signal, Dummy object) {
    ++count;
    signal.remove(this);
  }
}

void main() {
  group("Signal Tests", () {
    SignalTests tests = SignalTests();

    test("add listener and dispatch", tests.addListenerAndDispatch);
    test("add listeners and dispatch", tests.addListenersAndDispatch);
    test(
        "add listener dispatch and remove", tests.addListenerDispatchAndRemove);
    test("remove while dispatch", tests.removeWhileDispatch);
    test("remove all", tests.removeAll);
  });
}

class SignalTests {
  void addListenerAndDispatch() {
    Dummy dummy = Dummy();
    Signal<Dummy> signal = Signal<Dummy>();
    ListenerMock listener = ListenerMock();
    signal.add(listener);

    for (int i = 0; i < 10; ++i) {
      assertEquals(i, listener.count);
      signal.dispatch(dummy);
      assertEquals(i + 1, listener.count);
    }
  }

  void addListenersAndDispatch() {
    Dummy dummy = Dummy();
    Signal<Dummy> signal = Signal<Dummy>();
    List<ListenerMock> listeners = [];

    int numListeners = 10;

    while (listeners.length < numListeners) {
      ListenerMock listener = ListenerMock();
      listeners.add(listener);
      signal.add(listener);
    }

    int numDispatchs = 10;

    for (int i = 0; i < numDispatchs; ++i) {
      for (ListenerMock listener in listeners) {
        assertEquals(i, listener.count);
      }

      signal.dispatch(dummy);

      for (ListenerMock listener in listeners) {
        assertEquals(i + 1, listener.count);
      }
    }
  }

  void addListenerDispatchAndRemove() {
    Dummy dummy = Dummy();
    Signal<Dummy> signal = Signal<Dummy>();
    ListenerMock listenerA = ListenerMock();
    ListenerMock listenerB = ListenerMock();

    signal.add(listenerA);
    signal.add(listenerB);

    int numDispatchs = 5;

    for (int i = 0; i < numDispatchs; ++i) {
      assertEquals(i, listenerA.count);
      assertEquals(i, listenerB.count);

      signal.dispatch(dummy);

      assertEquals(i + 1, listenerA.count);
      assertEquals(i + 1, listenerB.count);
    }

    signal.remove(listenerB);

    for (int i = 0; i < numDispatchs; ++i) {
      assertEquals(i + numDispatchs, listenerA.count);
      assertEquals(numDispatchs, listenerB.count);

      signal.dispatch(dummy);

      assertEquals(i + 1 + numDispatchs, listenerA.count);
      assertEquals(numDispatchs, listenerB.count);
    }
  }

  void removeWhileDispatch() {
    Dummy dummy = Dummy();
    Signal<Dummy> signal = Signal<Dummy>();
    RemoveWhileDispatchListenerMock listenerA =
        new RemoveWhileDispatchListenerMock();
    ListenerMock listenerB = ListenerMock();

    signal.add(listenerA);
    signal.add(listenerB);

    signal.dispatch(dummy);

    assertEquals(1, listenerA.count);
    assertEquals(1, listenerB.count);
  }

  void removeAll() {
    Dummy dummy = Dummy();
    Signal<Dummy> signal = Signal<Dummy>();

    ListenerMock listenerA = ListenerMock();
    ListenerMock listenerB = ListenerMock();

    signal.add(listenerA);
    signal.add(listenerB);

    signal.dispatch(dummy);

    assertEquals(1, listenerA.count);
    assertEquals(1, listenerB.count);

    signal.removeAllListeners();

    signal.dispatch(dummy);

    assertEquals(1, listenerA.count);
    assertEquals(1, listenerB.count);
  }
}
