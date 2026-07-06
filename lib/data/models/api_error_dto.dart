/// DTO representing the standardised API error response.
///
/// Example JSON:
/// ```json
/// { "status_code": 422, "error": "InvalidCredentials", "details": ["..."] }
/// ```
class ApiErrorDto {
  /// Creates an [ApiErrorDto] instance.
  const ApiErrorDto({
    required this.statusCode,
    required this.error,
    required this.details,
  });

  /// Creates an [ApiErrorDto] from a JSON map.
  factory ApiErrorDto.fromJson(Map<String, dynamic> json) {
    return ApiErrorDto(
      statusCode: json['status_code'] as int,
      error: json['error'] as String,
      details: (json['details'] as List<dynamic>).cast<String>(),
    );
  }

  /// The HTTP status code echoed by the API.
  final int statusCode;

  /// The machine-readable error code, used for localization mapping.
  final String error;

  /// Human-readable details about the error.
  final List<String> details;
}
