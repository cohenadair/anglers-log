import '../model/gen/anglerslog.pb.dart';

// Unique IDs for each field. These are stored in the database and should not
// be changed.
final atmosphereFieldIdTemperature = Id()
  ..uuid = "efabb5c4-1160-484c-8fdc-a62c71e8e417";
final atmosphereFieldIdWindSpeed = Id()
  ..uuid = "26fc9f13-9e0c-4117-af03-71cbd1a46fb8";
final atmosphereFieldIdWindDirection = Id()
  ..uuid = "3d5a136c-53d6-4198-a5fc-96cbfa620bcf";
final atmosphereFieldIdPressure = Id()
  ..uuid = "cade6d54-aa10-43ef-8741-4421c1a761aa";
final atmosphereFieldIdHumidity = Id()
  ..uuid = "2a799a3f-3eca-4a46-858c-88fb89e66e7b";
final atmosphereFieldIdVisibility = Id()
  ..uuid = "62705e70-9c6b-417d-9a5e-6f3cd59ffd80";
final atmosphereFieldIdMoonPhase = Id()
  ..uuid = "46754037-37bc-4db2-a25e-6cc396d3b815";
final atmosphereFieldIdSkyCondition = Id()
  ..uuid = "d1d6446b-d73d-4343-8f0d-77a51b4a0735";
final atmosphereFieldIdSunriseTimestamp = Id()
  ..uuid = "07a54092-b0dd-43bd-ab07-f26718b2dd7c";
final atmosphereFieldIdSunsetTimestamp = Id()
  ..uuid = "a6a440f4-66a5-4243-b1ce-f3ed4f0cbd66";

final List<Id> allAtmosphereFieldIds = [
  atmosphereFieldIdTemperature,
  atmosphereFieldIdWindSpeed,
  atmosphereFieldIdWindDirection,
  atmosphereFieldIdPressure,
  atmosphereFieldIdHumidity,
  atmosphereFieldIdVisibility,
  atmosphereFieldIdMoonPhase,
  atmosphereFieldIdSkyCondition,
  atmosphereFieldIdSunriseTimestamp,
  atmosphereFieldIdSunsetTimestamp,
];
