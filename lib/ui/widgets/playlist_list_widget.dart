import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/screens/home_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/playlist_item.dart';
import 'package:http/http.dart';

import '../../models/thumbnail.dart';

class PlaylistListWidget extends StatelessWidget {
  const PlaylistListWidget({
    super.key,
    this.content
  });
  final dynamic content;

  @override
  Widget build(BuildContext context) {
   final isAlbumContent = content.runtimeType.toString()=="AlbumContent";
    return SizedBox(
        height: 250,
      child: Column(
        children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Text(
               content.title,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              )),
          SizedBox(height: 5),
          Container(
            height: 200,
            //color: Colors.blueAccent,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: isAlbumContent?content.albumList.length: content.playlistList.length,
                itemBuilder: (_, index) {
                  if(isAlbumContent){
                    return ListItem(
                        title: content.albumList[index].title,
                        subtitle: content.albumList[index].artist,
                        thumbnail: content.albumList[index].thumbnail);
                  }
                  return ListItem(title: content.playlistList[index].title, subtitle: content.playlistList[index].description, thumbnail: content.playlistList[index].thumbnail);
                }),
          ),
        ], 
      ),
    );
  }
}


