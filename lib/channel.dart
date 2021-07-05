import 'package:film_tracker/controller/identity_controller.dart';
import 'package:film_tracker/controller/register_controller.dart';
import 'package:film_tracker/controller/user_controller.dart';
import 'package:film_tracker/model/user.dart';
import 'package:film_tracker/utility/html_template.dart';
import 'package:film_tracker/film_tracker.dart';

///
/// The channel initializes the application.
///
class FilmTrackerChannel extends ApplicationChannel
    implements AuthRedirectControllerDelegate {
  final HTMLRenderer htmlRenderer = HTMLRenderer();
  AuthServer? authServer;
  ManagedContext? context;

  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));

    final config = FilmTrackerConfiguration(options!.configurationFilePath!);

    context = contextWithConnectionInfo(config.database!);

    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  /// Construct the request channel.
  ///
  /// Return an instance of some [Controller] that will be the initial receiver
  /// of all [Request]s.
  ///
  /// This method is invoked after [prepare].
  @override
  Controller get entryPoint {
    final router = Router();

    /* OAuth 2.0 Endpoints */
    router.route("/auth/token").link(() => AuthController(authServer));

    router
        .route("/auth/form")
        .link(() => AuthRedirectController(authServer!, delegate: this));

    /* Create an account */
    router
        .route("/register")
        .link(() => Authorizer.basic(authServer!))!
        .link(() => RegisterController(context!, authServer!));

    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer!))!
        .link(() => IdentityController(context!));

    /* Gets all users or one specific user by id */
    router
        .route("/users/[:id]")
        .link(() => Authorizer.bearer(authServer!))!
        .link(() => UserController(context!, authServer!));

    return router;
  }

  ///
  /// Initializes the PostgresSQL connection.
  ///
  ManagedContext contextWithConnectionInfo(
    DatabaseConfiguration connectionInfo,
  ) {
    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();
    final psc = PostgreSQLPersistentStore(
      connectionInfo.username,
      connectionInfo.password,
      connectionInfo.host,
      connectionInfo.port,
      connectionInfo.databaseName,
    );

    return ManagedContext(dataModel, psc);
  }

  @override
  Future<String?> render(
    AuthRedirectController forController,
    Uri requestUri,
    String? responseType,
    String? clientID,
    String? state,
    String? scope,
  ) async {
    final map = {
      "response_type": responseType,
      "client_id": clientID,
      "state": state
    };

    map["path"] = requestUri.path;
    if (scope != null) {
      map["scope"] = scope;
    }

    return htmlRenderer.renderHTML("web/login.html", map);
  }
}

/// An instance of this class represents values from a configuration
/// file specific to this application.
///
/// Configuration files must have key-value for the properties in this class.
/// For more documentation on configuration files, see
/// https://pub.dartlang.org/packages/safe_config.
class FilmTrackerConfiguration extends Configuration {
  FilmTrackerConfiguration(String fileName) : super.fromFile(File(fileName));

  DatabaseConfiguration? database;
}
