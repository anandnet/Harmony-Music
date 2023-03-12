import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'basic_container.dart';

class SongListShimmer extends StatelessWidget {
  const SongListShimmer({super.key, this.itemCount = 10});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
          itemCount: itemCount,
          padding: const EdgeInsets.all( 0),
          itemBuilder: (_, index) {
            return _listTile();
          }),
    );
  }

  Widget _listTile() {
    return const ListTile(
      leading: BasicShimmerContainer(Size(50, 50)),
      title: BasicShimmerContainer(Size(90, 20)),
      subtitle: BasicShimmerContainer(Size(40, 15)),
      trailing: BasicShimmerContainer(Size(50, 20)),
    );
  }
}
