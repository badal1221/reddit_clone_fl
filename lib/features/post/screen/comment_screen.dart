import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_f/core/common/post_card.dart';
import 'package:reddit_clone_f/features/post/controller/post_controller.dart';
import 'package:reddit_clone_f/features/post/widget/comment_card.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../models/post_model.dart';
import '../../auth/controller/auth_controller.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key,required this.postId});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController=TextEditingController();
  @override
  void dispose(){
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post){
    ref.watch(postControllerProvider.notifier).addComment(context: context,
        text:commentController.text.trim(),
        post: post);
    setState(() {
      commentController.text='';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !(user.isAuthenticated);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: ref.watch(getPostById(widget.postId)).when(data: (post) {
        return Column(
          children: [
            PostCard(post: post),
            if(!isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: TextField(
                    onSubmitted: (val) => addComment(post),
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Comment here',
                      filled: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ref.watch(getPostCommentsProvider(widget.postId)).when(
                data: (data) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (BuildContext context, int index) {
                          final comment = data[index];
                          return CommentCard(comment: comment);
                        }),
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader()),
          ],
        );
      },
          error: (error, stackTrace) =>
              ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
