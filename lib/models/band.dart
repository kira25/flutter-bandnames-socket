// To parse this JSON data, do
//
//     final band = bandFromJson(jsonString);

import 'dart:convert';

Band bandFromJson(String str) => Band.fromJson(json.decode(str));

String bandToJson(Band data) => json.encode(data.toJson());

class Band {
    Band({
        this.id,
        this.name,
        this.votes,
    });

    String id;
    String name;
    int votes;

    factory Band.fromJson(Map<String, dynamic> json) => Band(
        id: json["id"],
        name: json["name"],
        votes: json["votes"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "votes": votes,
    };
}
