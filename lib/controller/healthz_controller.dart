import 'package:film_tracker/film_tracker.dart';

class HealthzController extends Controller {
  @override
  FutureOr<RequestOrResponse?> handle(Request request) => Response.ok('OK');
}
