import 'package:flutter/material.dart';

class SortWidget extends StatefulWidget {
  const SortWidget({
    super.key,
    this.itemCountTitle ='',
    this.titleLeftPadding = 18,
    this.isDateOptionRequired = false,
    this.isDurationOptionRequired = false,
    required this.onSort,
  });
  final String itemCountTitle;
  final double titleLeftPadding;
  final bool isDurationOptionRequired;
  final bool isDateOptionRequired;
  final Function(bool sortByName, bool sortByDate, bool sortByDuration,
      bool isAscending) onSort;

  @override
  State<SortWidget> createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget> {
  bool sortByName = true;
  bool isAscending = true;
  bool sortByDate = false;
  bool sortByDuration = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left:widget.titleLeftPadding),
          child: Text(widget.itemCountTitle),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.sort_by_alpha_rounded),
              iconSize: 20,
              splashRadius: 20,
              visualDensity: const VisualDensity(horizontal: -3,vertical: -3),
              onPressed: () {
                widget.onSort(sortByName, sortByDate, sortByDuration, isAscending);
                setState(() {
                  sortByName = true;
                  sortByDate = false;
                  sortByDuration = false;
                });
              },
              color: sortByName
                  ? Theme.of(context).textTheme.bodySmall!.color
                  : Theme.of(context).colorScheme.secondary,
            ),
            widget.isDateOptionRequired
                ? IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    iconSize: 20,
                    splashRadius: 20,
                    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                    onPressed: () {
                      widget.onSort(
                          sortByName, sortByDate, sortByDuration, isAscending);
                      setState(() {
                        sortByName = false;
                        sortByDate = true;
                        sortByDuration = false;
                      });
                    },
                    color: sortByDate
                        ? Theme.of(context).textTheme.bodySmall!.color
                        : Theme.of(context).colorScheme.secondary)
                : const SizedBox.shrink(),
            widget.isDurationOptionRequired
                ? IconButton(
                    icon: const Icon(Icons.timer_rounded),
                    iconSize: 20,
                    splashRadius: 20,
                    visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                    onPressed: () {
                      widget.onSort(
                          sortByName, sortByDate, sortByDuration, isAscending);
                      setState(() {
                        sortByName = false;
                        sortByDate = false;
                        sortByDuration = true;
                      });
                    },
                    color: sortByDuration
                        ? Theme.of(context).textTheme.bodySmall!.color
                        : Theme.of(context).colorScheme.secondary)
                : const SizedBox.shrink(),
            const SizedBox(
              width: 40,
            ),
            IconButton(
              icon: isAscending
                  ? const Icon(Icons.arrow_downward_rounded)
                  : const Icon(Icons.arrow_upward_rounded),
              iconSize: 20,
              splashRadius: 20,
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              onPressed: () {
                widget.onSort(sortByName, sortByDate, sortByDuration, isAscending);
                setState(() {
                  isAscending = !isAscending;
                });
              },
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),
      ],
    );
  }
}
