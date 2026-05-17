import 'package:flutter/widgets.dart';

import 'local_attachment_image_io.dart'
    if (dart.library.html) 'local_attachment_image_web.dart'
    as impl;

Widget buildLocalAttachmentImage({
  required String path,
  required BoxFit fit,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return impl.buildLocalAttachmentImage(
    path: path,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
