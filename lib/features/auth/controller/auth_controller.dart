import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils.dart';
import '../../../models/user_model.dart';
import '../repository/auth_repository.dart';

final authControllerProvider=StateNotifierProvider<AuthController,bool>(
        (ref) => AuthController(authRepository: ref.watch(authRepositoryProvider),ref: ref));

final authStateChangeProvider=StreamProvider((ref){
  final authController=ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

final userProvider=StateProvider<UserModel?>((ref)=>null);

class AuthController extends StateNotifier<bool>{
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({required AuthRepository authRepository,required Ref ref}):
        _authRepository=authRepository,_ref=ref,
        super(false);//here it represent loading part

  Stream<User?> get authStateChange=>_authRepository.authStateChange;

  void signInWithGoogle(BuildContext context,bool isFromLogin) async{
    state=true;
    final user=await _authRepository.signInWithGoogle(isFromLogin);
    state=false;
    user.fold((l) => showSnackBar(context,l.message),
            (userModel) => _ref.read(userProvider.notifier).update((state) => userModel));//l=>failute,r=>success

  }

  void signInAsGuest(BuildContext context) async{
    state=true;
    final user=await _authRepository.signInAsGuest();
    state=false;
    user.fold((l) => showSnackBar(context,l.message),
            (userModel) => _ref.read(userProvider.notifier).update((state) => userModel));//l=>failute,r=>success

  }


  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
  void logOut()async{
    _authRepository.logOut();
  }
}