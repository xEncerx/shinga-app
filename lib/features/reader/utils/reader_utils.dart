/// Generates a Google search URL based on a given query string.
///
/// The [query] parameter is the string to search for (e.g. a title name).
String buildGoogleSearchUrl(String query) {
  final uri = Uri.https('www.google.com', '/search', {'q': query});
  return uri.toString();
}
