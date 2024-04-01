import 'package:flutter/material.dart';
import 'package:exchangeit/Objects/NotificationClass.dart';

class NotificationTile extends StatelessWidget {
  final NotificationObj notificationObj;
  final VoidCallback remove;
  final VoidCallback accept;
  final VoidCallback reject;

  NotificationTile(
      {required this.notificationObj,
      required this.remove,
      required this.accept,
      required this.reject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  child: ClipOval(
                      child: Image.network(
                    notificationObj.profilePic,
                    fit: BoxFit.cover,
                  )),
                  backgroundColor: Colors.white,
                  radius: 50,
                ),
                Flexible(
                  child: Column(
                    children: [
                      Text(
                        notificationObj.user + ", " + notificationObj.action,
                      )
                    ],
                  ),
                ),
                IconButton(
                    onPressed: remove,
                    icon:
                        const Icon(Icons.delete, size: 28, color: Colors.red)),
              ],
            ),
            notificationObj.type == 'yes'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(onPressed: accept, child: Text("Accept")),
                      TextButton(onPressed: reject, child: Text("Reject"))
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
