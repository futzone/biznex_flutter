import 'entity_event.dart';

class CloudEventIngestion {
  final List<Map<String, dynamic>> events;
  final String batchId;

  CloudEventIngestion({
    required this.events,
    required this.batchId,
  });

  Map<String, dynamic> toJson() => {"batchId": batchId, "events": events};
}

class CloudEvent {
  final Entity entityType;
  final EntityEvent eventType;
  final String entityId;
  final int entityVersion;
  final String payloadVersion;
  final Map<String, dynamic> data;
  final int eventSeq;
  final String id;

  CloudEvent({
    required this.entityType,
    required this.eventType,
    required this.entityId,
    required this.entityVersion,
    required this.payloadVersion,
    required this.data,
    required this.eventSeq,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType.name,
      'eventType': eventType.getName(),
      'entityId': entityId,
      'entityVersion': entityVersion,
      'payloadVersion': payloadVersion,
      'data': data,
      'deviceTimestamp': DateTime.now().toIso8601String(),
      'eventSeq': eventSeq,
      'id':id,
    };
  }
}
