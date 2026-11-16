import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:library_management_system/features/books/data/datasources/open_library_remote_data_source.dart';

void main() {
  test('looks up ISBN and maps Open Library search results', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'openlibrary.org');
      expect(request.url.path, '/search.json');
      expect(request.url.queryParameters['isbn'], '9780132350884');
      return http.Response(
        '{"docs":[{"title":"Clean Code","subtitle":"A Handbook",'
        '"author_name":["Robert C. Martin"],"publisher":["Prentice Hall"],'
        '"first_publish_year":2008,"cover_i":12345}]}',
        200,
      );
    });
    final dataSource = OpenLibraryRemoteDataSource(client: client);

    final result = await dataSource.lookupByIsbn('978-0-13-235088-4');

    expect(result?.title, 'Clean Code: A Handbook');
    expect(result?.author, 'Robert C. Martin');
    expect(result?.publisher, 'Prentice Hall');
    expect(result?.publicationYear, 2008);
    expect(
      result?.coverImage,
      'https://covers.openlibrary.org/b/id/12345-L.jpg',
    );
  });

  test('returns null when Open Library has no matching ISBN', () async {
    final client = MockClient(
      (_) async => http.Response('{"docs":[]}', 200),
    );
    final dataSource = OpenLibraryRemoteDataSource(client: client);

    expect(await dataSource.lookupByIsbn('9780132350884'), isNull);
  });
}
