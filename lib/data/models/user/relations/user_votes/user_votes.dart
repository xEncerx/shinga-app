import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_votes.freezed.dart';
part 'user_votes.g.dart';

@freezed
abstract class UserVotes with _$UserVotes {
  /// Represents the votes given by a user.
  /// - `total` - The total number of votes.
  /// - `vote_n` - The number of votes for each rating from 1 to 10.
  const factory UserVotes({
    required int total,
    required int vote_1,
    required int vote_2,
    required int vote_3,
    required int vote_4,
    required int vote_5,
    required int vote_6,
    required int vote_7,
    required int vote_8,
    required int vote_9,
    required int vote_10,
  }) = _UserVotes;

  factory UserVotes.fromJson(Map<String, dynamic> json) => _$UserVotesFromJson(json);

  /// Creates a dummy UserVotes
  static const UserVotes dummy = UserVotes(
    total: 0,
    vote_1: 0,
    vote_2: 0,
    vote_3: 0,
    vote_4: 0,
    vote_5: 0,
    vote_6: 0,
    vote_7: 0,
    vote_8: 0,
    vote_9: 0,
    vote_10: 0,
  );
}
