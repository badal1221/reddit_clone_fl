import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_f/core/common/error_text.dart';
import 'package:reddit_clone_f/core/common/loader.dart';
import 'package:reddit_clone_f/features/community/controller/community_controller.dart';
import 'package:reddit_clone_f/features/post/controller/post_controller.dart';
import 'package:routemaster/routemaster.dart';
import '../../features/auth/controller/auth_controller.dart';
import '../../models/post_model.dart';
import '../../theme/pallete.dart';
import '../constants/constants.dart';

class PostCard extends ConsumerWidget{
  final Post post;
  const PostCard({super.key,required this.post});

  void deletePost(WidgetRef ref,BuildContext context){
    ref.read(postControllerProvider.notifier).deletePost(post,context);
  }
  void upvotePost(WidgetRef ref){
    ref.read(postControllerProvider.notifier).upvote(post);
  }
  void downvotePost(WidgetRef ref){
    ref.read(postControllerProvider.notifier).downvote(post);
  }
  void awardPost(WidgetRef ref,String award,BuildContext context){
    ref.read(postControllerProvider.notifier).awardPost(
        post: post, 
        award: award, 
        context: context);
  }
  void navigateToUserProfile(BuildContext context){
    Routemaster.of(context).push('/u/${post.uid}');
  }
  void navigateToCommunity(BuildContext context){
    Routemaster.of(context).push('/r/${post.communityName}');
  }
  void navigateToComment(BuildContext context){
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context,WidgetRef ref){
    final isTypeImage=post.type=='image';
    final isTypeText=post.type=='text';
    final isTypeLink=post.type=='link';
    final currentTheme=ref.watch(themeNotifierProvider);
    final user=ref.watch(userProvider)!;
    final isGuest=!(user.isAuthenticated);
    return Container(
      decoration: BoxDecoration(
        color:currentTheme.drawerTheme.backgroundColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child:Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap:()=>navigateToCommunity(context),
                              child: CircleAvatar(
                                backgroundImage:NetworkImage(post.communityProfilePic,
                                ),
                                radius: 16,
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:()=>navigateToCommunity(context),
                                    child: Text('r/${post.communityName}',style:const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                       ),),
                                  ),
                                  GestureDetector(onTap:()=>navigateToUserProfile(context) ,
                                      child: Text('u/${post.username}',style:const TextStyle(fontSize:12,),)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if(post.uid==user.uid)
                          IconButton(onPressed:()=>deletePost(ref,context),
                            icon:Icon(Icons.delete,
                              color: Pallete.redColor,),),
                      ],
                    ),
                    if(post.awards.isNotEmpty)...[
                      const SizedBox(height: 5,),
                      SizedBox(height: 25,
                        child: ListView.builder(
                            scrollDirection:Axis.horizontal,
                            itemCount: post.awards.length,
                            itemBuilder:(BuildContext context,int index){
                              final award=post.awards[index];
                              return Image.asset(Constants.awards[award]!,height: 23,);
                            }
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(right:10),
                      child: Text(post.title,style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                    const SizedBox(height:5,),
                    if(isTypeImage)
                       SizedBox(height: MediaQuery.of(context).size.height*0.35,
                         width: double.infinity,
                         child: Image.network(post.link!,
                         fit: BoxFit.cover,),
                       ),
                    if(isTypeLink)
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 18),
                         child:AnyLinkPreview(
                           displayDirection: UIDirection.uiDirectionHorizontal,
                           link: post.link!,
                         ),
                       ),
                    if(isTypeText)
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(post.description!,style:const TextStyle(color: Colors.grey,),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(onPressed:isGuest?(){}:()=>upvotePost(ref),
                                icon:Icon(Constants.up,
                                  size: 30,
                                color: post.upvotes.contains(user.uid)?Pallete.redColor:null,),),
                            Text('${post.upvotes.length-post.downvotes.length==0?'Vote':post.upvotes.length-post.downvotes.length}',
                            style: TextStyle(
                              fontSize: 17,
                            ),),
                            IconButton(onPressed:isGuest?(){}:()=>downvotePost(ref),
                              icon:Icon(Constants.down,
                                size: 30,
                                color: post.downvotes.contains(user.uid)?Pallete.blueColor:null,),),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(onPressed:()=>navigateToComment(context),
                              icon:const Icon(Icons.comment),),
                            Text('${post.commentCount==0?'Comment':post.commentCount}')
                          ],
                        ),
                        ref.watch(getCommunityByNameProvider(post.communityName)).when(
                            data: (data){
                              if(data.mods.contains(user.uid)){
                                return IconButton(onPressed:()=>deletePost(ref, context),
                                  icon:Icon(Icons.admin_panel_settings,),);
                              }
                              return SizedBox();
                            },
                            error: (error,stackTrace)=>ErrorText(error: error.toString()),
                            loading:()=>const Loader()
                        ),
                        if(post.uid!=user.uid)
                          IconButton(onPressed:isGuest?(){}:(){
                            showDialog(context: context,
                              builder:(context)=>Dialog(
                                child:Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:4),
                                    itemCount: user.awards.length,
                                    itemBuilder: (BuildContext context,int index){
                                      final award=user.awards[index];
                                      return GestureDetector(
                                        onTap:()=>awardPost(ref, award, context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(Constants.awards[award]!),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                              icon:const Icon(Icons.card_giftcard_outlined),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              //const SizedBox(height: 10,),
              const Divider(),
            ],
           ),
          ),
        ],
      ),
    );
  }
}