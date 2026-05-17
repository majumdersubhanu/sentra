import 'dart:io';

import 'package:flutter/widgets.dart';

Widget buildLocalAttachmentImage({
  required String path,
  required BoxFit fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(File(path), fit: fit, errorBuilder: errorBuilder);
}
