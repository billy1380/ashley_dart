import 'package:test/test.dart';
import './core/component_operation_handler_tests.dart' as t1;
import './core/component_type_tests.dart'as t2;
import './core/engine_tests.dart'as t3;
import './core/entity_listener_tests.dart'as t4;
import './core/entity_manager_dart.dart'as t5;
import './core/entity_test.dart'as t6;
import './core/family_manager_tests.dart'as t7;
import './core/family_tests.dart'as t8;
import './core/system_manager_tests.dart'as t9;
import './signals/signal_tests.dart'as t10;
import './systems/interval_iterating_test.dart'as t11;
import './systems/interval_system_test.dart'as t12;
import './systems/iterating_system_test.dart'as t13;
import './systems/sorted_iterating_system_test.dart'as t14;

void main() {
  group("All tests", () {
    t1.main();
    t2.main();
    t3.main();
    t4.main();
    t5.main();
    t6.main();
    t7.main();
    t8.main();
    t9.main();
    t10.main();
    t11.main();
    t12.main();
    t13.main();
    t14.main();
  });
}
