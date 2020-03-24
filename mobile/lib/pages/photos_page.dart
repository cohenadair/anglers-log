import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/string_utils.dart';
import 'package:mobile/widgets/widget.dart';

class PhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(format(Strings.of(context).photosPageTitle, [0])),
      ),
      body: Empty(),
    );
  }
}