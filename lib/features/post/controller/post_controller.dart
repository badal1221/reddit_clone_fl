import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_f/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone_f/features/post/repository/post_repository.dart';
import 'package:reddit_clone_f/models/community_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/storage_repository_provider.dart';
import '../../../core/utils.dart';
import '../../../models/post_model.dart';


final postControllerProvider=StateNotifierProvider<PostController,bool>((ref) =>
    PostController(postRepository: ref.watch(postRepositoryProvider),
      ref: ref,storageRepository: ref.watch(storageRepositoryProvider),
    )
);

class PostController extends StateNotifier<bool>{
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({required PostRepository postRepository,
    required Ref ref,required StorageRepository storageRepository, })
      :_postRepository=postRepository,
        _ref=ref,
        _storageRepository=storageRepository,
        super(false);

  void shareTextPost({
        required BuildContext context,
        required String title,
        required Community selectedCommunity,
        required String description,})async{

    state=true;
    String postId=const Uuid().v1();
    final user=_ref.read(userProvider)!;
    final Post post=Post(id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type:'text' ,
        createdAt:DateTime.now() ,
        awards:[],
        description:description
    );
    final res=await _postRepository.addPost(post);
    state=false;
    res.fold((l) =>showSnackBar(context,l.message),
            (r){
              showSnackBar(context,'Posted Successfully');
              Routemaster.of(context).pop();
            });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,})async{

    state=true;
    String postId=const Uuid().v1();
    final user=_ref.read(userProvider)!;
    final Post post=Post(id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type:'link' ,
        createdAt:DateTime.now() ,
        awards:[],
        link: link
    );
    final res=await _postRepository.addPost(post);
    state=false;
    res.fold((l) =>showSnackBar(context,l.message),
            (r){
          showSnackBar(context,'Posted Successfully');
          Routemaster.of(context).pop();
        });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,})async{

    state=true;
    String postId=const Uuid().v1();
    final user=_ref.read(userProvider)!;
    final imageRes=await _storageRepository.storeFile(path:'posts/${selectedCommunity.name}',
        id:postId,
        file: file);
    imageRes.fold((l) =>showSnackBar(context,l.message),
            (r)async{
              final Post post=Post(id: postId,
                title: title,
                communityName: selectedCommunity.name,
                communityProfilePic: selectedCommunity.avatar,
                upvotes: [],
                downvotes: [],
                commentCount: 0,
                username: user.name,
                uid: user.uid,
                type:'link' ,
                createdAt:DateTime.now() ,
                awards:[],
                link: r
              );
              final res=await _postRepository.addPost(post);
              state=false;
              res.fold((l) =>showSnackBar(context,l.message),
                      (r){
                    showSnackBar(context,'Posted Successfully');
                    Routemaster.of(context).pop();
                  });
            });

  }
}