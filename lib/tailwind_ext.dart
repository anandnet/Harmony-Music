import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';

/// define the custom size here
extension SizeExt<T extends SizeBuilder> on T {
  T get h210 => this..height = 210.h;

  T get w210 => this..width = 210.w;

  T get s210 => this..size = 210.r;
}

/// define the custom text feature here
extension TextFeatureExt<T extends TextFeature> on T {
  ///T get fontExample => this..fontFamily = 'font family,just define family here';
}

/// define the custom text size here
extension FontSizeExt<T extends FontSizeBuilder> on T {
  ///T get f120 => this..font(120.csp);
}

/// define the custom icon here
extension IconExt<T extends IconBuilder> on T {
  ///T get icDefAvatar => this..icon(R.icDefAvatar);
}

/// define the custom text style here,text feature just single feature,but style is completed style,can directly use it
extension TextStyleExt<T extends CompletedTextStyleBuilder> on T {
  T get styleMain => this..style = ts.redAccent.f16.bold.underline.mk;

  /// use flutter tailwind style
  T get styleAccent => this..style = ts.greenAccent.f20.bold.underline.mk;

  /// use flutter normal style to describe text style
  T get styleTradition => this
    ..style = TextStyle(
      color: Colors.greenAccent,
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );
}

/// define the shadow
extension ShadowExt<T extends ShadowBuilder> on T {
  T get customShadow => this
    ..boxShadow = const [
      BoxShadow(
        color: Color(0x78000000),
        offset: Offset(0, 4),
        blurRadius: 4,
      )
    ];
}

/// You can define the default style which just explain you how to define the style with flutter tailwind
extension DecorationExt<T extends CompleteDecoration> on T {
  /// use flutter tailwind BoxDecoration
  T get decorMain => this..decoration = bd.greenAccent.circle.borderBrown.rounded8.customShadow.border5.mk;

  /// Use flutter normal style to describe BoxDecoration
  T get decorTradition => this
    ..decoration = BoxDecoration(
        color: Colors.greenAccent,
        border: Border.all(color: Colors.brown, width: 5.r),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x78000000),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ]);
}