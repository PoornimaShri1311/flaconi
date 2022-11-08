import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

import 'package:music_app/main.dart' as app;
import 'package:music_app/resources/resources.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

extension on WidgetTester {
  Future<void> pumpApp() async {
    app.main();
    await pumpAndSettle();
  }

  Future<void> tapSearch() async {
    var searchButton = find.byIcon(Icons.search);
    await tap(searchButton);
    await pumpAndSettle();
  }

  Future<void> searchAlbums(String searchTerm) async {
    /// Find TextFormField widget by Key and enter text
    await enterText(find.byType(TextField), searchTerm);

    // wait a seconds for success view
    await pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> selectFirstArtist() async {
    var foundArtists = find.image(const AssetImage(Images.star));
    await tap(foundArtists.first);
    await pumpAndSettle();
  }

  Future<void> likeAlbum() async {
    var foundAlbums = find.byIcon(Icons.favorite);
    await tap(foundAlbums.first);
    // wait a seconds for success view
    await pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> searchNaddAlbums(String searchTerm) async {
    await searchAlbums(searchTerm);
    await tapSearch();
    await selectFirstArtist();
    await likeAlbum();
    await tap(find.byTooltip('Back'));
    await pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> back() async {
    await tap(find.byTooltip('Back'));
    await pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> HomeScreenAlbums() async {
    // check if the selected Albums shows in the screen
    await pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> albumDetails() async {
    // check the album details
    await pumpAndSettle(const Duration(seconds: 1));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late NavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  testWidgets('Music App E2E', (tester) async {
    // load the app
    await tester.pumpApp();

    // check appbar title
    expect(find.text('Music App'), findsOneWidget);

    // check for the "No Albums added yet" for the first time app run
    expect(find.text('No Albums added yet'), findsOneWidget);

    // check for search widget
    var searchButton = find.byIcon(Icons.search);
    expect(searchButton, findsOneWidget);

    await tester.tapSearch();
    // check for the search route
    expect(find.byType(TextField), findsOneWidget);

    // // test search feature working
    // await tester.searchAlbums("eminem");
    // await tester.tapSearch();

    // expect(find.image(const AssetImage(Images.star)), findsWidgets);
    // expect(find.text('eminem'), findsOneWidget);

    // await tester.searchAlbums("invalidalbums123");
    // await tester.tapSearch();

    // expect(find.image(const AssetImage(Images.star)), findsNothing);

    // expect(find.text('Somthin wrong happens!'), findsOneWidget);

    // search and like few albums
    await tester.searchNaddAlbums("eminem");
    await tester.searchNaddAlbums("akon");
    await tester.searchNaddAlbums("Drake");
    await tester.back();
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));

    // search for album which results in no albums found

    // check for all the liked albums present in home screen
    await tester.HomeScreenAlbums();

    // check if all the albums has details page
    await tester.albumDetails();

    // wait a seconds for success view
    await tester.pump(const Duration(seconds: 10));

    // check for details page
  });
}
