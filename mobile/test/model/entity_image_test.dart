import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/entity_image.dart';

void main() {
  test("Mapping", () {
    var image = EntityImage(
      entityId: "ID0",
      imageName: "Name0",
    );

    var map = image.toMap();
    expect(map["entity_id"], "ID0");
    expect(map["image_name"], "Name0");

    map = {
      "entity_id" : "ID1",
      "image_name" : "Name1",
    };
    image = EntityImage.fromMap(map);
    expect(image.entityId, "ID1");
    expect(image.imageName, "Name1");
  });
}