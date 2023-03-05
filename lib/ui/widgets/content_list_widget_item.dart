import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harmonymusic/ui/screens/playlist_screen.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem({super.key,required this.content});
  ///content will be of Type class Album or Playlist
  final dynamic content;
  

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == "Album";
    return InkWell(
      onTap: () => !isAlbum? Navigator.of(context).push(MaterialPageRoute(builder: (_)=>PlayListScreen(playlist:content))):(){},
      child: Container(
        width: 140,
        padding: const EdgeInsets.only(left:10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height:120,child: CachedNetworkImage(imageUrl: content.thumbnailUrl,cacheKey: isAlbum?"${content.browseId}_album":"${content.playlistId}_plalist",)),
            const SizedBox(height:5),
            Text(content.title,
             // overflow: TextOverflow.ellipsis,
             maxLines: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(isAlbum?content.artist:content.description,maxLines: 1,style: Theme.of(context).textTheme.titleSmall,),
          ],
        ),
      ),
    );
  }
}