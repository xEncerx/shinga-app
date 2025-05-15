part of 'searching_bloc.dart';

sealed class SearchingEvent extends Equatable{
  const SearchingEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSearchingHistory extends SearchingEvent {}
final class ClearSearchingHistory extends SearchingEvent {}
final class AddSearchingHistoryValue extends SearchingEvent {
  const AddSearchingHistoryValue(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

final class SearchManga extends SearchingEvent {
  const SearchManga(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}
