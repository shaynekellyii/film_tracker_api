import 'package:film_tracker/model/user.dart';
import 'package:film_tracker/film_tracker.dart';
import 'package:conduit_test/conduit_test.dart';

export 'package:film_tracker/film_tracker.dart';
export 'package:conduit_test/conduit_test.dart';
export 'package:test/test.dart';
export 'package:conduit/conduit.dart';

/// A testing harness for film_tracker.
///
/// A harness for testing an conduit application. Example test file:
///
///         void main() {
///           Harness harness = Harness()..install();
///
///           test("Make request", () async {
///             final response = await harness.agent.get("/path");
///             expectResponse(response, 200);
///           });
///         }
///
class Harness extends TestHarness<FilmTrackerChannel>
    with TestHarnessAuthMixin<FilmTrackerChannel>, TestHarnessORMMixin {
  @override
  ManagedContext? get context => channel?.context;

  @override
  AuthServer? get authServer => channel?.authServer;

  Agent? publicAgent;

  @override
  Future onSetUp() async {
    // add initialization code that will run once the test application has started
    await resetData();

    publicAgent = await addClient("com.conduit.public");
  }

  Future<Agent> registerUser(User user, {Agent? withClient}) async {
    withClient ??= publicAgent;

    final req = withClient!.request("/register")
      ..body = {"username": user.username, "password": user.password};
    await req.post();

    return loginUser(withClient, user.username!, user.password!);
  }
}
