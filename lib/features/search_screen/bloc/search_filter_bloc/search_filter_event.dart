part of 'search_filter_bloc.dart';

sealed class SearchFilterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class LoadFilterData extends SearchFilterEvent {}
