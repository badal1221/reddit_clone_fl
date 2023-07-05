import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_f/core/constants/constants.dart';
import 'package:reddit_clone_f/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone_f/features/community/repository/community_repository.dart';
import 'package:reddit_clone_f/models/community_model.dart';
import 'package:routemaster/routemaster.dart';
import '../../../core/utils.dart';

final userCommunitiesProvider=StreamProvider((ref){
  final communityController=ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunity();
});

final communityControllerProvider=StateNotifierProvider<CommunityController,bool>(
        (ref) => CommunityController(communityRepository: ref.watch(communityRepositoryProvider),ref: ref));

final getCommunityByNameProvider=StreamProvider.family((ref,String name){
  return ref.watch(communityControllerProvider.notifier).getCommunityByName(name);
});


class CommunityController extends StateNotifier<bool>{
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController({required CommunityRepository communityRepository,
    required Ref ref})
      :_communityRepository=communityRepository,
        _ref=ref,
        super(false);

  void createCommunity(String name,BuildContext context)async{
    state=true;
    final uid=_ref.read(userProvider)?.uid??'';
     Community community=Community(id: name,
         name: name,
         banner: Constants.bannerDefault,
         avatar: Constants.avatarDefault,
         members: [uid],
         mods: [uid]);
     final res=await _communityRepository.createCommunity(community);//if failure response the show snackbar showing reason
    state=false;
    res.fold((l)=>showSnackBar(context,l.message),(r){
       showSnackBar(context,'Community created successfully');
       Routemaster.of(context).pop();
     });
  }
  Stream<List<Community>> getUserCommunity(){
    final uid=_ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommmunity(uid);
  }
  Stream<Community> getCommunityByName(String name){
    return _communityRepository.getCommunityByName(name);
  }
}