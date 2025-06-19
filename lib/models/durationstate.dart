class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  Duration current;
  Duration buffered;
  Duration total;
}
