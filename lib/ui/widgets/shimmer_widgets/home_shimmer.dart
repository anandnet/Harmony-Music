import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'basic_container.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[500]!,
        highlightColor: Colors.grey[300]!,
        enabled: true,
        direction: ShimmerDirection.ltr,
        child: Column(
          children: [_discoverWidget(), _contentWidget(), _contentWidget()],
        ));
  }

  Widget _discoverWidget() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: BasicShimmerContainer(Size(220, 30)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: .26 / 1,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 5,
                ),
                itemBuilder: (_, item) {
                  return const ListTile(
                    contentPadding: EdgeInsetsDirectional.all(5),
                    leading: BasicShimmerContainer(Size(50, 50)),
                    title: BasicShimmerContainer(Size(90, 20)),
                    subtitle: BasicShimmerContainer(Size(40, 15)),
                  );
                }),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  Widget _contentWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 5),
          child: BasicShimmerContainer(Size(220, 30)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          //color: Colors.blueAccent,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, index) {
                return Container(
                  width: 140,
                  padding: const EdgeInsets.only(left: 5.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 120,
                          child: BasicShimmerContainer(Size(120, 120))),
                      SizedBox(height: 5),
                      BasicShimmerContainer(Size(115, 20)),
                      SizedBox(height: 5),
                      BasicShimmerContainer(Size(90, 15)),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
