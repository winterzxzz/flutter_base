import 'package:json_annotation/json_annotation.dart';

part 'example_item.g.dart';

@JsonSerializable()
class ExampleItem {
  const ExampleItem({this.id = '', this.title = ''});

  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String title;

  factory ExampleItem.fromJson(Map<String, dynamic> json) =>
      _$ExampleItemFromJson(json);

  Map<String, dynamic> toJson() => _$ExampleItemToJson(this);
}
