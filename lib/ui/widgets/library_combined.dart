import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Library/library.dart';

class CombinedLibrary extends StatelessWidget{
  const CombinedLibrary({super.key});

  
  @override
  Widget build(BuildContext context) {
    final tabCon = Get.put(CombinedLibraryController());
    return  Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Theme.of(context).primaryColor,
        bottom:  TabBar(
          controller: tabCon.tabController,
          tabs: [
            Tab(text: "songs".tr),
            Tab(text:"playlists".tr),
            Tab(text: "albums".tr),
            Tab(text: "artists".tr),
          ],
        ),
        title: Padding(
          padding: const EdgeInsets.only(top:60.0),
          child: Text('library'.tr,style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
      body: TabBarView(
        controller: tabCon.tabController,
        children: const [
          SongsLibraryWidget(isBottomNavActive: true,),
          PlaylistNAlbumLibraryWidget(isAlbumContent: false, isBottomNavActive: true),
          PlaylistNAlbumLibraryWidget(isBottomNavActive: true),
          LibraryArtistWidget(isBottomNavActive: true),
        ],
      ),
    );
  }
}

class CombinedLibraryController extends GetxController with GetSingleTickerProviderStateMixin{
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 4);
  }
}