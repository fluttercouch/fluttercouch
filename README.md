# fluttercouch

With Fluttercouch is possible to use Couchbase Mobile Native SDK in Flutter Projects.

The plugin takes advantage of Flutter ability to write platform specific code to instantiate and manage a Couchbase Lite database. The fluttercouch library is a wrapper to native SDK, which is handled from Dart through "mockup" objects. Those objects are responsible for creating local database, making CRUD operation and sync with a Couchbase database through platform channels.

None of the Dart objects actually holds the actual state (which is hold in the native code). They are an interface to operate the native SDK in an easy and feasible manner, helping developers to not deal with native layer directly.

## Roadmap
The first goal is to implement all software parts needed to run the starter code listed <a href="https://developer.couchbase.com/documentation/mobile/2.0/couchbase-lite/java.html">here</a> in Flutter.

The aim is to construct a "zero-documentation" plugin that can be used by simply following the Couchbase Mobile Documentation for other platform. Therefore, any adaptation to the Flutter style has to be optional althought strongly desirable, such as integration with Inherited Widgets or other Flutter plugins that manage data and model layers.

The FlutterCouch plugin is still under development and any contribution is welcome.

## Current development

By now, the library can create (in an Android device) a database locally and replicate a couchbase server database by connecting to a sync gateway. It can retrieve a Document by id and extract any “usual” field (no blob) and save it back to the Database.
Queries are still missing, but are under development.
The iOs native code will be implemented after Android implementation is confirmed as a good approach for queries too, so that middleware code would not be written twice.

Any suggestion or feebdack are appreciated.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
