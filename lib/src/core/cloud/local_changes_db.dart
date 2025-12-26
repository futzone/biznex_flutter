import 'package:biznex/src/core/cloud/change_versions_db.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'entity_event.dart';

class LocalChanges {
  static final LocalChanges instance = LocalChanges._internal();

  factory LocalChanges() => instance;

  LocalChanges._internal();

  final Uuid _uuid = Uuid();
  final ChangeVersionsDB _versionsDB = ChangeVersionsDB();
  final String _changesBox = "changes_box";

  Future<void> saveChange({
    required EntityEvent event,
    required Entity entity,
    required String objectId,
  }) async {
    final Change change = Change(
      id: _uuid.v8(),
      entityType: entity,
      eventType: event,
      deviceTimestamp: DateTime.now(),
      entityId: objectId,
      entityVersion: await _versionsDB.getEntityVersion(objectId),
      eventSeq: await _versionsDB.getEventSeq(),
    );

    final box = await Hive.openBox(_changesBox);
    await box.put(change.id, change.toJson());
  }

  Future<void> deleteChange(String id) async {
    final box = await Hive.openBox(_changesBox);
    await box.delete(id);
  }

  Future<List<Change>> getChanges({int limit = 50}) async {
    final box = await Hive.openBox(_changesBox);
    List<Change> changesList = [];
    for (final item in box.values) {
      if (changesList.length < 50) {
        changesList.add(Change.fromJson(item));
      } else {
        return changesList;
      }
    }

    return changesList;
  }
}

class Change {
  String id;
  Entity entityType;
  EntityEvent eventType;
  DateTime deviceTimestamp;
  String entityId;
  int entityVersion;
  int eventSeq;

  Change({
    required this.id,
    required this.entityType,
    required this.eventType,
    required this.deviceTimestamp,
    required this.entityId,
    required this.entityVersion,
    required this.eventSeq,
  });

  factory Change.fromJson(Map<String, dynamic> json) {
    return Change(
      id: json['id'] as String,
      entityType: Entity.values.byName(json['entityType'] as String),
      eventType: EntityEvent.byName(json['eventType'] as String),
      deviceTimestamp: DateTime.parse(json['deviceTimestamp'] as String),
      entityId: json['entityId'] as String,
      entityVersion: json['entityVersion'] as int,
      eventSeq: json['eventSeq'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType.name,
      'eventType': eventType.getName(),
      'deviceTimestamp': deviceTimestamp.toIso8601String(),
      'entityId': entityId,
      'entityVersion': entityVersion,
      'eventSeq': eventSeq,
    };
  }
}
