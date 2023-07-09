import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_f/core/constants/firebase_constants.dart';
import '../../../core/failure.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/type_defs.dart';
import '../../../models/comment_model.dart';
import '../../../models/community_model.dart';
import '../../../models/post_model.dart';


final postRepositoryProvider=Provider((ref)=>PostRepository(firestore: ref.watch(firestoreProvider)));
class PostRepository{
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore}):_firestore=firestore;

  CollectionReference get _posts=>_firestore.collection(FirebaseConstants.postsCollection);
  CollectionReference get _comments=>_firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _users=>_firestore.collection(FirebaseConstants.usersCollection);
  FutureVoid addPost(Post post) async{
    try{
      return right(_posts.doc(post.id).set(post.toMap()));
    }on FirebaseException catch(e) {
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }
  Stream<List<Post>> fetchUserPosts(List<Community> communities){
    return _posts
        .where('communityName',whereIn: communities.map((e) => e.name).toList())//searched posts whose communityName is the name of community
        .orderBy('createdAt',descending: true)//ordered the list the result
        .snapshots()
        .map(
            (event) =>event.docs
                .map(
                    (e) => Post.fromMap(
                        e.data() as Map<String,dynamic>,
                    ),
            ).toList(),
    );
  }

  FutureVoid deletePost(Post post)async{
    try{
      return right(_posts.doc(post.id).delete());
    }on FirebaseException catch(e){
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }
  void upvote(Post post,String userId)async{
      if(post.downvotes.contains(userId)){
         _posts.doc(post.id).update({
            'downvotes':FieldValue.arrayRemove([userId]),
      });}//if down voted already then remove it
      else if(post.upvotes.contains(userId)){
        _posts.doc(post.id).update({
          'upvotes':FieldValue.arrayRemove([userId]),
        });}//if already upvoted thenn remove it
      else{
        _posts.doc(post.id).update({
          'upvotes':FieldValue.arrayUnion([userId]),
        });
      }
  }
  void downvote(Post post,String userId)async{
    if(post.downvotes.contains(userId)){
      _posts.doc(post.id).update({
        'downvotes':FieldValue.arrayRemove([userId]),
      });}//if down voted already then remove it
    else if(post.upvotes.contains(userId)){
      _posts.doc(post.id).update({
        'upvotes':FieldValue.arrayRemove([userId]),
      });}//if already upvoted thenn remove it
    else{
      _posts.doc(post.id).update({
        'downvotes':FieldValue.arrayUnion([userId]),
      });
    }
  }
  Stream<Post> getPostById(String postId){
      return _posts.doc(postId).snapshots().map(
              (event) =>Post.fromMap(
                  event.data() as Map<String,dynamic>
              )
      );
  }
  FutureVoid addComment(Comment comment)async{
    try{
      await _comments.doc(comment.id).set(comment.toMap());//added our comment to _comments
      return right(_posts.doc(comment.postId).update({
        'commentCount':FieldValue.increment(1),
      }));//update the comment count of a specific post
    }on FirebaseException catch(e){
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Comment>> getCommentsOfPosts(String postId){
    return _comments.where('postId',isEqualTo:postId)
        .orderBy('createdAt',descending: true).snapshots().map(
            (event) => event.docs
            .map(
              (e) =>Comment.fromMap(
            e.data() as Map<String,dynamic>,
          ),
        ).toList()
    );
  }

  FutureVoid awardPost(Post post,String award,String senderId)async{
    try{
      _posts.doc(post.id).update({
        'awards':FieldValue.arrayUnion([award]),
      });//give award to post
      _users.doc(senderId).update({
        'awards':FieldValue.arrayRemove([award]),
      });//remove award from doner
      return right(_users.doc(post.uid).update({
        'awards':FieldValue.arrayUnion([award]),
      }));//gift award to the one who posted the post
    }on FirebaseException catch(e){
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchGuestPosts(){
    return _posts
        .orderBy('createdAt',descending: true).limit(10)
        .snapshots()
        .map(
          (event) =>event.docs
          .map(
            (e) => Post.fromMap(
          e.data() as Map<String,dynamic>,
        ),
      ).toList(),
    );
  }
}