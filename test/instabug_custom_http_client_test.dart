import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instabug_dart_io_http_client/src/http_client_logger.dart';
import 'package:instabug_dart_io_http_client/src/instabug_custom_http_client.dart';
import 'package:instabug_dart_io_http_client/src/instabug_custom_http_client_request.dart';
import 'package:instabug_flutter/instabug_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'instabug_custom_http_client_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  HttpClientLogger,
  HttpClientRequest,
  HttpClientResponse,
  HttpClientCredentials,
  NetworkLogger,
  NetworkData,
  HttpHeaders,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> log = <MethodCall>[];
  const String url = 'https://jsonplaceholder.typicode.com';
  const int port = 8888;
  const String path = '/posts';
  const body = {'testKey': 'testValue'};
  const listOfObjects = [
    {'test1': 'test'},
    {'test2': 'test'},
    {'test3': 'test'}
  ];

  late InstabugCustomHttpClient instabugCustomHttpClient;
  late InstabugCustomHttpClientRequest instabugCustomHttpClientRequest;
  late MockHttpClientRequest mockRequest;
  late MockHttpClientResponse mockResponse;
  late MockNetworkLogger mockNetworkLogger;
  late MockNetworkData mockNetworkData;
  late MockHttpHeaders mockHttpHeaders;

  setUpAll(() async {
    const MethodChannel('instabug_flutter')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });
  });

  setUp(() {
    instabugCustomHttpClient = InstabugCustomHttpClient();
    instabugCustomHttpClient.client = MockHttpClient();
    instabugCustomHttpClient.logger = MockHttpClientLogger();

    mockRequest = MockHttpClientRequest();
    mockResponse = MockHttpClientResponse();
    mockNetworkLogger = MockNetworkLogger();
    mockNetworkData = MockNetworkData();
    mockHttpHeaders = MockHttpHeaders();

    when(mockRequest.bufferOutput).thenAnswer((_) => true);
    when(mockRequest.contentLength).thenAnswer((_) => 100);
    when(mockRequest.encoding).thenAnswer((_) => systemEncoding);
    when(mockRequest.followRedirects).thenAnswer((_) => true);
    when(mockRequest.maxRedirects).thenAnswer((_) => 5);
    when(mockRequest.persistentConnection).thenAnswer((_) => true);
    when(mockRequest.headers).thenAnswer((_) => mockHttpHeaders);
    when(mockResponse.headers).thenAnswer((_) => mockHttpHeaders);
    when(mockNetworkData.requestBody).thenAnswer((_) => '');
    when(mockResponse.statusCode).thenAnswer((_) => 0);
    when(mockNetworkData.startTime)
        .thenAnswer((_) => DateTime.parse('2021-10-25'));
    when(mockHttpHeaders.contentType).thenAnswer((_) => ContentType.json);

    instabugCustomHttpClientRequest = InstabugCustomHttpClientRequest(
        mockRequest, instabugCustomHttpClient.logger);

    expect(mockRequest, isInstanceOf<HttpClientRequest>());
    expect(mockResponse, isInstanceOf<HttpClientResponse>());

    when<dynamic>(mockRequest.close()).thenAnswer((_) async => mockResponse);
  });

  tearDown(() async {
    log.clear();
  });

  test('expect instabug custom http client GET URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).getUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.getUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client GET to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .get(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.get(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test(
      'expect instabug custom http client DELETE URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).deleteUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.deleteUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client DELETE to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .delete(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.delete(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect onResponse to call networkLog method', () async {
    final HttpClientLogger clientLogger = HttpClientLogger();
    when<dynamic>(mockNetworkData.copyWith(
      url: anyNamed('url'),
      method: anyNamed('method'),
      requestBody: anyNamed('requestBody'),
      requestBodySize: anyNamed('requestBodySize'),
      responseBodySize: anyNamed('responseBodySize'),
      status: anyNamed('status'),
      requestHeaders: anyNamed('requestHeaders'),
      responseHeaders: anyNamed('responseHeaders'),
      duration: anyNamed('duration'),
      requestContentType: anyNamed('requestContentType'),
      responseContentType: anyNamed('responseContentType'),
      endTime: anyNamed('endTime'),
      startTime: anyNamed('startTime'),
      errorCode: anyNamed('errorCode'),
      errorDomain: anyNamed('errorDomain'),
    )).thenReturn(mockNetworkData);
    when<dynamic>(mockNetworkData.toMap()).thenReturn(<String, dynamic>{});
    when<dynamic>(mockNetworkLogger.networkLog(any))
        .thenAnswer((realInvocation) => Future<bool>(() => true));

    clientLogger.requests[mockRequest.hashCode] = mockNetworkData;
    clientLogger.networkLogger = mockNetworkLogger;

    clientLogger.onResponse(mockResponse, mockRequest);

    verify(mockNetworkLogger.networkLog(any));
  });

  test('expect instabug custom http client POST URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test(
      'expect instabug custom http client request WRITE to call onRequestUpdate',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    instabugCustomHttpClientRequest.write(body.toString());
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger
        .onRequestUpdate(mockRequest, requestBody: body.toString()));
  });

  test(
      'expect instabug custom http client request WRITELN to call onRequestUpdate',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    instabugCustomHttpClientRequest.writeln(body.toString());
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger
        .onRequestUpdate(mockRequest, requestBody: '$body\n'));
  });

  test(
      'expect instabug custom http client request WRITE CHARCODE to call onRequestUpdate',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    instabugCustomHttpClientRequest.writeCharCode(97);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger
        .onRequestUpdate(mockRequest, requestBody: 'a'));
  });

  test(
      'expect instabug custom http client request WRITE ALL to call onRequestUpdate',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    instabugCustomHttpClientRequest.writeAll(listOfObjects);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequestUpdate(mockRequest,
        requestBody: listOfObjects[0].toString() +
            listOfObjects[1].toString() +
            listOfObjects[2].toString()));
  });
  test('expect instabug custom http client POST to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .post(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.post(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client HEAD URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).headUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.headUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client HEAD to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .head(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.head(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client PATCH URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).patchUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.patchUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client PATCH to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .patch(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.patch(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client OPEN URL to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .openUrl(any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.openUrl('GET', Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client OPEN to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .open(any, any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.open('GET', url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client PUT URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).putUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.putUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client PUT to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .put(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.put(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client POST URL to return request and log',
      () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).postUrl(any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.postUrl(Uri.parse(url));
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client POST to return request and log',
      () async {
    when<dynamic>((instabugCustomHttpClient.client as MockHttpClient)
            .post(any, any, any))
        .thenAnswer((_) async => mockRequest);

    await instabugCustomHttpClient.post(url, port, path);
    await instabugCustomHttpClientRequest.close();

    verify(instabugCustomHttpClient.logger.onRequest(mockRequest));
    verify(
        instabugCustomHttpClient.logger.onResponse(mockResponse, mockRequest));
  });

  test('expect instabug custom http client to get client autoUncompress',
      () async {
    when((instabugCustomHttpClient.client as MockHttpClient).autoUncompress)
        .thenReturn(true);
    expect(instabugCustomHttpClient.autoUncompress, true);
  });

  test('expect instabug custom http client to set client autoUncompress',
      () async {
    instabugCustomHttpClient.autoUncompress = false;
    verify((instabugCustomHttpClient.client as MockHttpClient).autoUncompress =
            false)
        .called(1);
  });

  test('expect instabug custom http client to get client connectionTimout',
      () async {
    when((instabugCustomHttpClient.client as MockHttpClient).connectionTimeout)
        .thenReturn(const Duration(seconds: 2));
    expect(
        instabugCustomHttpClient.connectionTimeout, const Duration(seconds: 2));
  });

  test('expect instabug custom http client to set client connectionTimout',
      () async {
    instabugCustomHttpClient.connectionTimeout = const Duration(seconds: 5);
    verify((instabugCustomHttpClient.client as MockHttpClient)
            .connectionTimeout = const Duration(seconds: 5))
        .called(1);
  });

  test('expect instabug custom http client to get client idleTimeout',
      () async {
    when((instabugCustomHttpClient.client as MockHttpClient).idleTimeout)
        .thenReturn(const Duration(seconds: 2));
    expect(instabugCustomHttpClient.idleTimeout, const Duration(seconds: 2));
  });

  test('expect instabug custom http client to set client idleTimeout',
      () async {
    instabugCustomHttpClient.idleTimeout = const Duration(seconds: 5);
    verify((instabugCustomHttpClient.client as MockHttpClient).idleTimeout =
            const Duration(seconds: 5))
        .called(1);
  });

  test('expect instabug custom http client to get client maxConnectionsPerHost',
      () async {
    when((instabugCustomHttpClient.client as MockHttpClient)
            .maxConnectionsPerHost)
        .thenReturn(2);
    expect(instabugCustomHttpClient.maxConnectionsPerHost, 2);
  });

  test('expect instabug custom http client to set client maxConnectionsPerHost',
      () async {
    instabugCustomHttpClient.maxConnectionsPerHost = 5;
    verify((instabugCustomHttpClient.client as MockHttpClient)
            .maxConnectionsPerHost = 5)
        .called(1);
  });

  test('expect instabug custom http client to get client userAgent', () async {
    when((instabugCustomHttpClient.client as MockHttpClient).userAgent)
        .thenReturn('2');
    expect(instabugCustomHttpClient.userAgent, '2');
  });

  test('expect instabug custom http client to set client userAgent', () async {
    instabugCustomHttpClient.userAgent = 'something';
    verify((instabugCustomHttpClient.client as MockHttpClient).userAgent =
            'something')
        .called(1);
  });

  test('expect instabug custom http client to call client addClientCredentials',
      () async {
    const String realm = 'realm string';
    final MockHttpClientCredentials clientCredentials =
        MockHttpClientCredentials();
    instabugCustomHttpClient.addCredentials(
        Uri.parse(url), realm, clientCredentials);
    verify(instabugCustomHttpClient.client
            .addCredentials(Uri.parse(url), realm, clientCredentials))
        .called(1);
  });

  test('expect instabug custom http client to call client addProxyCredentials',
      () async {
    const String realm = 'realm string';
    final MockHttpClientCredentials clientCredentials =
        MockHttpClientCredentials();
    instabugCustomHttpClient.addProxyCredentials(
        url, port, realm, clientCredentials);
    verify(instabugCustomHttpClient.client
            .addProxyCredentials(url, port, realm, clientCredentials))
        .called(1);
  });

  test('expect instabug custom http client to set client authenticate',
      () async {
    final Future<bool> Function(Uri url, String scheme, String realm) f =
        (Uri url, String scheme, String? realm) async => true;

    instabugCustomHttpClient.authenticate =
        f as Future<bool> Function(Uri url, String scheme, String? realm);
    verify((instabugCustomHttpClient.client as MockHttpClient).authenticate = f)
        .called(1);
  });

  test('expect instabug custom http client to set client authenticateProxy',
      () async {
    final Future<bool> Function(
            String host, int port, String scheme, String realm) f =
        (String host, int port, String scheme, String? realm) async => true;
    instabugCustomHttpClient.authenticateProxy = f as Future<bool> Function(
        String host, int port, String scheme, String? realm);
    verify((instabugCustomHttpClient.client as MockHttpClient)
            .authenticateProxy = f)
        .called(1);
  });

  test(
      'expect instabug custom http client to set client badCertificateCallback',
      () async {
    final bool Function(X509Certificate cert, String host, int port) f =
        (X509Certificate cert, String host, int port) => true;
    instabugCustomHttpClient.badCertificateCallback = f;
    verify((instabugCustomHttpClient.client as MockHttpClient)
            .badCertificateCallback = f)
        .called(1);
  });

  test('expect instabug custom http client to call client close', () async {
    instabugCustomHttpClient.close(force: true);
    verify((instabugCustomHttpClient.client as MockHttpClient)
            .close(force: true))
        .called(1);
  });

  test('Stress test on GET URL method', () async {
    when<dynamic>(
            (instabugCustomHttpClient.client as MockHttpClient).getUrl(any))
        .thenAnswer((_) async => mockRequest);

    for (int i = 0; i < 10000; i++) {
      await instabugCustomHttpClient.getUrl(Uri.parse(url));
      await instabugCustomHttpClientRequest.close();
    }

    verify((instabugCustomHttpClient.logger as MockHttpClientLogger)
            .onRequest(any))
        .called(10000);
    verify((instabugCustomHttpClient.logger as MockHttpClientLogger)
            .onResponse(any, any))
        .called(10000);
  });
}
