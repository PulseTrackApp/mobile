import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/core/modules/app_module.dart';
import 'package:mobile_flutter/core/modules/module_access_controller.dart';

void main() {
  test("verrouille les modules tant que l'API n'a pas repondu", () {
    final state = ModuleAccessState.allLocked();

    expect(state.isEnabled(AppModule.workouts), isFalse);
    expect(state.isEnabled(AppModule.bodyCheckins), isFalse);
    expect(state.isEnabled(AppModule.goals), isFalse);
    expect(state.isEnabled(AppModule.stats), isFalse);
    expect(state.isEnabled(AppModule.weeklySummary), isFalse);
    expect(state.isEnabled(AppModule.coach), isFalse);
    expect(state.isEnabled(AppModule.export), isFalse);
    expect(state.isEnabled(AppModule.push), isFalse);
  });
}
