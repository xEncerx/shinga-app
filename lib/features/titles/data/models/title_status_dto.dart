import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shinga/domain/domain.dart';

/// The current publication status of a title.
@JsonEnum(valueField: 'value')
enum TitleStatusDTO {
  /// The title is actively being published.
  ongoing('ongoing'),

  /// The title has completed publication.
  finished('finished'),

  /// Publication has been permanently stopped.
  discontinued('discontinued'),

  /// Publication is temporarily on hold.
  frozen('frozen'),

  /// The title has been announced but not yet released.
  anons('anons'),

  /// The publication status is not known.
  unknown('unknown');

  const TitleStatusDTO(this.value);

  /// The string value corresponding to the enum case, matching API responses.
  final String value;

  @override
  String toString() => value;

  /// Converts a string value from the API to the corresponding [TitleStatusDTO] enum case.
  static TitleStatusDTO fromValue(String value) => TitleStatusDTO.values.firstWhere(
    (e) => e.value == value,
    orElse: () => TitleStatusDTO.unknown,
  );

  /// Converts this DTO to the [TitleStatus] domain entity.
  TitleStatus toDomain() => switch (this) {
    TitleStatusDTO.ongoing => TitleStatus.ongoing,
    TitleStatusDTO.finished => TitleStatus.finished,
    TitleStatusDTO.discontinued => TitleStatus.discontinued,
    TitleStatusDTO.frozen => TitleStatus.frozen,
    TitleStatusDTO.anons => TitleStatus.anons,
    TitleStatusDTO.unknown => TitleStatus.unknown,
  };

  /// Converts a [TitleStatus] domain entity to this DTO.
  static TitleStatusDTO fromDomain(TitleStatus status) => switch (status) {
    TitleStatus.ongoing => TitleStatusDTO.ongoing,
    TitleStatus.finished => TitleStatusDTO.finished,
    TitleStatus.discontinued => TitleStatusDTO.discontinued,
    TitleStatus.frozen => TitleStatusDTO.frozen,
    TitleStatus.anons => TitleStatusDTO.anons,
    TitleStatus.unknown => TitleStatusDTO.unknown,
  };
}
