class Thumbnail {
  Thumbnail(this._url);
  final String _url;
  String sizewith(int size) =>
      (_url.contains("piped") || _url.contains("i.ytimg.com"))
          ? url
          : "${_url.split("=")[0]}=w$size-h$size-l90-rj";
  String get url => _url;
  String get high => sizewith(400); //450
  String get medium => sizewith(250); //350
  String get low => sizewith(150); //150
}
