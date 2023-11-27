// import 'package:flutter/material.dart';
// import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';

// ///Sample Netease style
// ///should be extends LyricUI implementation your own UI.
// ///this property only for change UI,if not demand just only overwrite methods.
// class CustomUIShazam extends LyricUI {
//   double defaultSize;
//   double defaultExtSize;
//   double otherMainSize;
//   double bias;
//   double lineGap;
//   double inlineGap;
//   LyricAlign lyricAlign;
//   LyricBaseLine lyricBaseLine;
//   bool highlight;
//   HighlightDirection highlightDirection;

//   CustomUIShazam(
//       {this.defaultSize = 30,
//       this.defaultExtSize = 22,
//       this.otherMainSize = 16,
//       this.bias = 0.5,
//       this.lineGap = 25,
//       this.inlineGap = 25,
//       this.lyricAlign = LyricAlign.CENTER,
//       this.lyricBaseLine = LyricBaseLine.CENTER,
//       this.highlight = false,
//       this.highlightDirection = HighlightDirection.LTR});

//   CustomUIShazam.clone(CustomUIShazam CustomUIShazam)
//       : this(
//           defaultSize: CustomUIShazam.defaultSize,
//           defaultExtSize: CustomUIShazam.defaultExtSize,
//           otherMainSize: CustomUIShazam.otherMainSize,
//           bias: CustomUIShazam.bias,
//           lineGap: CustomUIShazam.lineGap,
//           inlineGap: CustomUIShazam.inlineGap,
//           lyricAlign: CustomUIShazam.lyricAlign,
//           lyricBaseLine: CustomUIShazam.lyricBaseLine,
//           highlight: CustomUIShazam.highlight,
//           highlightDirection: CustomUIShazam.highlightDirection,
//         );

//   @override
//   TextStyle getPlayingExtTextStyle() =>
//       TextStyle(color: Colors.grey[300], fontSize: defaultExtSize);

//   @override
//   TextStyle getOtherExtTextStyle() => TextStyle(
//         color: Colors.grey[300],
//         fontSize: defaultExtSize,
//       );

//   @override
//   TextStyle getOtherMainTextStyle() =>
//       TextStyle(color: Colors.white.withOpacity(0.8), fontSize: otherMainSize);

//   @override
//   TextStyle getPlayingMainTextStyle() => TextStyle(
//         color: Colors.white,
//         fontWeight: FontWeight.bold,
//         fontSize: defaultSize,
//       );

//   @override
//   double getInlineSpace() => inlineGap;

//   @override
//   double getLineSpace() => lineGap;

//   @override
//   double getPlayingLineBias() => bias;

//   @override
//   LyricAlign getLyricHorizontalAlign() => lyricAlign;

//   @override
//   LyricBaseLine getBiasBaseLine() => lyricBaseLine;

//   @override
//   bool enableHighlight() => highlight;

//   @override
//   HighlightDirection getHighlightDirection() => highlightDirection;
// }
