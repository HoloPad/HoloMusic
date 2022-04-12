import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../ServerRequests/User.dart';

class ProfileCard extends StatelessWidget {
  User user;

  ProfileCard(this.user, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => print("CLICK ${user.id}"),
        hoverColor: AppStyle.primaryBackground.withOpacity(0.6),
        child: Card(
            color: AppStyle.primaryBackground,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: TextStyle(
                            color: AppStyle.textStyle.color, fontSize: 20),
                      ),
                      Text(
                        AppLocalizations.of(context)!.publicPlaylist +
                            " " +
                            user.public_playlist_count.toString(),
                        style: TextStyle(
                            color: AppStyle.textStyle.color?.withOpacity(0.8),
                            fontSize: 12),
                      )
                    ]))));
  }
}
