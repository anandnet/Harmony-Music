import 'package:flutter/material.dart';
import 'package:harmonymusic/models/album.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/widgets/content_list_widget_item.dart';
import 'package:harmonymusic/ui/widgets/marqwee_widget.dart';

class ContentListWidget extends StatelessWidget {
  ///ContentListWidget is used to render a section of Content like a list of Albums or Playlists in HomeScreen
  const ContentListWidget({super.key, this.content});
  
  ///content will be of class Type AlbumContent or PlaylistContent
  final dynamic content;

  @override
  Widget build(BuildContext context) {
    final isAlbumContent = content.runtimeType.toString() == "AlbumContent";
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            //maxLines: 2,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 200,
            //color: Colors.blueAccent,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: isAlbumContent
                    ? content.albumList.length
                    : content.playlistList.length,
                itemBuilder: (_, index) {
                  if (isAlbumContent) {
                    return ContentListItem(
                      content:content.albumList[index]
                    );
                  }
                  return ContentListItem(
                    content: content.playlistList[index]
                  );
                }),
          ),
        ],
      ),
    );
  }
}
