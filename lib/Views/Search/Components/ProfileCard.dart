import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holomusic/Common/Notifications/ReRenderNotification.dart';
import 'package:holomusic/Common/Parameters/AppStyle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:holomusic/Common/Storage/UserHistoryStorage.dart';
import '../../../ServerRequests/UserRequest.dart';

class ProfileCard extends StatelessWidget {
  User user;

  ProfileCard(this.user, {Key? key}) : super(key: key);

  void onCancelClicked(BuildContext context){
    UserHistoryStorage.deleteUser(user);
    ReRenderNotification().dispatch(context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => UserHistoryStorage.addUser(user),
        hoverColor: AppStyle.primaryBackground.withOpacity(0.6),
        child: Card(
            color: AppStyle.primaryBackground,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: TextStyle(
                                  color: AppStyle.textStyle.color,
                                  fontSize: 20),
                            ),
                            Text(
                              AppLocalizations.of(context)!.publicPlaylist +
                                  " " +
                                  user.public_playlist_count.toString(),
                              style: TextStyle(
                                  color: AppStyle.textStyle.color
                                      ?.withOpacity(0.8),
                                  fontSize: 12),
                            )
                          ]),
                      TextButton(
                          onPressed: ()=>onCancelClicked(context), child: const Icon(Icons.cancel_outlined))
                    ]))));
  }
}
