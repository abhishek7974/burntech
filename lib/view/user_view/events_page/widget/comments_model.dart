import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controller/comment_controller.dart';
import '../../../../core/firebase_constant/firebase_constants.dart';
import '../../../../widget/custom_text_form_field.dart';

class CommentModel extends ConsumerStatefulWidget {
  final String eventId;

  CommentModel({required this.eventId});

  @override
  ConsumerState<CommentModel> createState() => _CommentModelState();
}

class _CommentModelState extends ConsumerState<CommentModel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final commentData = ref.watch(commentController);
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events/${widget.eventId}/comments")
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments yet.'));
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return FutureBuilder(
                          future: commentData.fetchUserData(comment['userId']),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData ||
                                !userSnapshot.data!.exists) {
                              return Center(child: Text(''));
                            }

                            final userData = userSnapshot.data!.data();
                            final userName =
                                userData?['name'] ?? 'Unknown User';
                            final userProfileImage = userData?[
                                    'profileImage'] ??
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKydNzoaNd7bkwENwlshdrHfsavKUloX5UMg&s';
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(userProfileImage),
                                radius: 20,
                              ),
                              title: Text(
                                userName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(comment['comment']),
                            );
                          });
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextFormField(
                        controller: commentData.commentCont,
                        hintText: 'Add a comment...',
                        suffix: IconButton(
                          onPressed: () {
                            commentData.addComment(
                                commentData.commentCont.text.trim(),
                                widget.eventId);
                          },
                          icon: Icon(
                            Icons.send,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showCommentsModal(context),
      child: Icon(Icons.comment),
    ); //   text: "View comments ",
  }
}
