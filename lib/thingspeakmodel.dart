// To parse this JSON data, do
//
//     final thinkSpeakModel = thinkSpeakModelFromJson(jsonString);

import 'dart:convert';

ThinkSpeakModel thinkSpeakModelFromJson(String str) =>
    ThinkSpeakModel.fromJson(json.decode(str));

String thinkSpeakModelToJson(ThinkSpeakModel data) =>
    json.encode(data.toJson());

class ThinkSpeakModel {
  final Channel? channel;
  final List<Feed>? feeds;

  ThinkSpeakModel({
    this.channel,
    this.feeds,
  });

  factory ThinkSpeakModel.fromJson(Map<String, dynamic> json) =>
      ThinkSpeakModel(
        channel:
            json["channel"] == null ? null : Channel.fromJson(json["channel"]),
        feeds: json["feeds"] == null
            ? []
            : List<Feed>.from(json["feeds"]!.map((x) => Feed.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "channel": channel?.toJson(),
        "feeds": feeds == null
            ? []
            : List<dynamic>.from(feeds!.map((x) => x.toJson())),
      };
}

class Channel {
  final int? id;
  final String? name;
  final String? latitude;
  final String? longitude;
  final String? field1;
  final String? field2;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? lastEntryId;

  Channel({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.field1,
    this.field2,
    this.createdAt,
    this.updatedAt,
    this.lastEntryId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json["id"],
        name: json["name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        field1: json["field1"],
        field2: json["field2"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        lastEntryId: json["last_entry_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
        "field1": field1,
        "field2": field2,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "last_entry_id": lastEntryId,
      };
}

class Feed {
  final DateTime? createdAt;
  final int? entryId;
  final String? field1;
  final String? field2;

  Feed({
    this.createdAt,
    this.entryId,
    this.field1,
    this.field2,
  });

  factory Feed.fromJson(Map<String, dynamic> json) => Feed(
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        entryId: json["entry_id"],
        field1: json["field1"],
        field2: json["field2"],
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt?.toIso8601String(),
        "entry_id": entryId,
        "field1": field1,
        "field2": field2,
      };
}
