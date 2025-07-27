import 'package:flutter/material.dart';

import '../../../data/models/user/user.dart';
import '../../../i18n/strings.g.dart';
import '../../features.dart';

class UserCharts extends StatelessWidget {
  const UserCharts({
    super.key,
    required this.userData, required this.userVotes,
  });

  final UserData userData;
  final UserVotes userVotes;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: t.profile.charts.stats),
              Tab(text: t.profile.charts.votes),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                BookMarksChart(bookmarksCount: userData.countBookmarks),
                VotesChart(userVotes: userVotes),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
