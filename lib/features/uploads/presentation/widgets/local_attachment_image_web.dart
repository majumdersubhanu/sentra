import 'package:flutter/widgets.dart';

Widget buildLocalAttachmentImage({
  required String path,
  required BoxFit fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.network(path, fit: fit, errorBuilder: errorBuilder);
}
