import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_f/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone_f/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clone_f/features/home/drawers/profile_drawer.dart';
import 'package:reddit_clone_f/theme/pallete.dart';
import '../../../core/constants/constants.dart';
import '../../auth/controller/auth_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen>{
     int _page=0;


  void displayDrawer(BuildContext context){
    Scaffold.of(context).openDrawer();
  }
  void displayendDrawer(BuildContext context){
    Scaffold.of(context).openEndDrawer();
  }
  void onPageChanged(int page){
    setState(() {
      _page=page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user=ref.watch(userProvider)!;
    final isGuest=!(user.isAuthenticated);//if user is authenticated then not a guest
    final currentTheme=ref.watch(themeNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed:()=>displayDrawer(context),
              );
            }
          ),
        actions: [
          IconButton(onPressed: (){
            showSearch(context: context, delegate: SearchCommunityDelegates(ref));
          },
              icon: const Icon(Icons.search),),
          Builder(
            builder: (context) {
              return IconButton(
                icon: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                onPressed:()=>displayendDrawer(context),
              );
            }
          )
        ],
      ),
      body: Constants.tabWidget[_page],
      drawer:const CommunityListDrawer(),
      endDrawer:const ProfileDrawer(),
      bottomNavigationBar:isGuest? null:CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items:const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',),
        ],
        onTap:onPageChanged ,
        currentIndex: _page,
      ) ,
    );
  }

}

