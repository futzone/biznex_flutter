// import 'dart:convert';
// import 'package:hive/hive.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
//
// class WebSocketManager {
//   final List<WebSocketChannel> _clients = [];
//
//   void addClient(WebSocketChannel channel) {
//     _clients.add(channel);
//
//     _sendCurrentData(channel);
//
//     channel.stream.listen(
//       (message) {},
//       onDone: () {
//         _clients.remove(channel);
//       },
//       onError: (error) {
//         _clients.remove(channel);
//       },
//     );
//   }
//
//   void broadcast(dynamic data) {
//     final jsonData = jsonEncode(data);
//     for (final client in _clients) {
//       client.sink.add(jsonData);
//     }
//   }
//
//   void _sendCurrentData(WebSocketChannel client) async  {
//
//     final box = await Hive.openBox('orders_all');
//     final allData = box.values;
//     client.sink.add(jsonEncode({
//       'type': 'initial_data',
//       'data': [...allData],
//     }));
//   }
//
//   void startHiveListener() async {
//     final box = await  Hive.openBox('orders_all');
//     box.watch().listen((event) {
//       broadcast({
//         'key': event.key,
//         'value': event.value,
//         'deleted': event.deleted,
//       });
//     });
//   }
// }
