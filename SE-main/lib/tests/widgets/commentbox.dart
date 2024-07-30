import 'package:bookshare/tests/screens/otheruserprofile.dart';
import 'package:bookshare/tests/screens/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Commentbox extends StatelessWidget {
  const Commentbox(
      {super.key,
      required this.userName,
      required this.comment,
      required this.date,
      required this.userProfile,
      required this.id,
      required this.currentUserId,
      required this.commentUserId});

  final String currentUserId;
  final String commentUserId;
  final String id;
  final String userName;
  final String comment;
  final DateTime date;
  final String userProfile;

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('hh:mm a E-MMM-yyyy').format(date);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (currentUserId == commentUserId) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UserProfile()));
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Otheruserprofile(userId: id)));
              }  
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(userProfile),
              radius: 25,
            ),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    width: double.infinity,
                    child: Text.rich(
                        softWrap: true,
                        TextSpan(
                            text: '${userName}\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                  text: comment,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ]))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Commented at: ${formattedDate}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
