import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:harmonymusic/models/thumbnail.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key,required this.title,required this.subtitle,required this.thumbnail});
  final String title;
  final String subtitle;
  final Thumbnail thumbnail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.only(left:10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height:120,child: CachedNetworkImage(imageUrl: thumbnail.sizewith(120))),
          const SizedBox(height:5),
          Text(title,
           // overflow: TextOverflow.ellipsis,
           maxLines: 2,
            style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
          ),
          Text(subtitle,maxLines: 1,),
        ],
      ),
    );
  }
}