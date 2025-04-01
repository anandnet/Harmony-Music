import 'package:flutter/material.dart';

class PlaylistAlbumScrollBehaviour extends MaterialScrollBehavior {
   @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
