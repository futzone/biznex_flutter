import 'package:hive/hive.dart';

class ChangeVersionsDB {
  final String payloadVersion = "1.0.0";


  final String _entityVersionBox = "entity_version_box";
  final String _eventSeqBox = "event_seq_box";
  final String _eventSeqKey = "value";

  Future<int> getEventSeq() async {
    final box = await Hive.openBox(_eventSeqBox);
    final current = (await box.get(_eventSeqKey)) ?? 0;

    final eventSeq = current + 1;
    await box.put(_eventSeqKey, eventSeq);

    return eventSeq;
  }

  Future<int> getEntityVersion(String objectId) async {
    final box = await Hive.openBox(_entityVersionBox);
    final current = box.get(objectId) ?? 0;

    final entityVersion = current + 1;
    await box.put(objectId, entityVersion);

    return entityVersion;
  }

  Future<void> deleteEntityVersion(String objectId) async {
    final box = await Hive.openBox(_entityVersionBox);
    await box.delete(objectId);
  }
}
