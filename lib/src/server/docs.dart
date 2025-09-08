import 'package:biznex/src/server/requests.dart';
import 'dart:convert';

final encoder = const JsonEncoder.withIndent('  ');

class ApiRequest {
  String name;
  String path;
  Map<String, dynamic> params;
  Map<String, String> headers;
  Map<String, String> errorResponse;
  String method;
  String body;
  String contentType;
  dynamic response;

  ApiRequest({
    required this.name,
    required this.path,
    this.params = const {},
    this.headers = const {},
    required this.method,
    this.body = '',
    this.contentType = 'application/json',
    this.response,
    required this.errorResponse,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'path': path,
        'params': params,
        'headers': headers,
        'method': method,
        'body': body,
        'contentType': contentType,
        'response': response,
        'errorResponse': errorResponse,
      };

  factory ApiRequest.fromJson(Map<String, dynamic> json) {
    return ApiRequest(
      name: json['name'],
      path: json['path'],
      params: Map<String, dynamic>.from(json['params'] ?? {}),
      headers: Map<String, String>.from(json['headers'] ?? {}),
      method: json['method'],
      body: json['body'] ?? '',
      contentType: json['contentType'] ?? 'application/json',
      response: json['response'],
      errorResponse: json['errorResponse'],
    );
  }
}

String renderApiRequests() {
  final requests = serverRequestsList();
  String htmlContent = '''
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Biznex Waiters Docs</title>
    <style>
      body { font-family: sans-serif; padding: 20px; }
      .request-box { border: 1px solid #ccc; padding: 16px; margin-bottom: 20px; border-radius: 8px; }
      .request-box h2 { margin: 0 0 10px 0; }
      .method { font-weight: bold; color: white; padding: 4px 8px; border-radius: 4px; }
      .GET { background: green; }
      .POST { background: blue; }
      .PUT { background: orange; }
      .DELETE { background: red; }
      textarea { width: 100%; height: 100px; }
      pre { background: #eee; padding: 10px; border-radius: 4px; }
    </style>
  </head>
  <body>
    <h1>🧩 Biznex Waiters Api Docs</h1>
  ''';

  for (var request in requests) {
    final formattedResponse = encoder.convert(request.response ?? {});
    final formattedError = encoder.convert(request.errorResponse ?? {});

    htmlContent += '''
  <div class="request-box">
    <h2 onclick="toggleSection('${request.path.hashCode}${request.method.toLowerCase()}')">${request.name}</h2>
    <div id="section-${request.path.hashCode}${request.method.toLowerCase()}" style="display:none;">
      <div><span class="method ${request.method}">${request.method}</span> <code>${request.path}</code></div>
      <pre>Request headers: ${request.headers}</pre>
      <pre>Request params: ${request.params}</pre>
      <pre>Request body: ${request.body}</pre>
      <pre class="code-block language-json">$formattedResponse</pre>
      <pre class="code-block language-json">$formattedError</pre>
    </div>
  </div>
  ''';
  }


  htmlContent += '''
  <script>
    function sendRequest(method, path, body) {
      fetch(path, {
        method: method,
        headers: { 'Content-Type': 'application/json' },
        body: body ? JSON.stringify(body) : undefined
      })
      .then(response => response.text())
      .then(data => document.getElementById('response-' + path).textContent = data)
      .catch(error => document.getElementById('response-' + path).textContent = 'Error: ' + error);
    }
  </script>
  <script>
  function toggleSection(id) {
    const section = document.getElementById('section-' + id);
    if (section.style.display === 'none') {
      section.style.display = 'block';
    } else {
      section.style.display = 'none';
    }
  }
</script>

  </body>
  </html>
  ''';

  return htmlContent;
}
