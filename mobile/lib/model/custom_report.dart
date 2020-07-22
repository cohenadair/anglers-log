import 'package:flutter/material.dart';
import 'package:mobile/model/named_entity.dart';
import 'package:mobile/model/report.dart';
import 'package:quiver/strings.dart';

class CustomReport extends NamedEntity implements Report {
  CustomReport({
    @required String name,
    String id,
  }) : assert(isNotEmpty(name)),
       super(id: id, name: name);

  CustomReport.fromMap(Map<String, dynamic> map) : super.fromMap(map);

  @override
  String title(BuildContext context) => super.name;
}