// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'nav_parser.dart';

const CONTINUATION_TOKEN = [
  "continuationItemRenderer",
  "continuationEndpoint",
  "continuationCommand",
  "token"
];
const CONTINUATION_ITEMS = [
  "onResponseReceivedActions",
  0,
  "appendContinuationItemsAction",
  "continuationItems"
];

String? getContinuationToken(List<dynamic> results) {
  return nav(results.last, CONTINUATION_TOKEN);
}

Future<List> getContinuationsPlaylist(Map<String, dynamic> results, int? limit,
    Function requestFunc, Function parseFunc) async {
  List<dynamic> items = [];
  String? continuationToken = getContinuationToken(results['contents']);

  while (continuationToken != null && (limit == null || items.length < limit)) {
    try {
      final response = await requestFunc({"continuation": continuationToken});
      final continuationItems = nav(response, CONTINUATION_ITEMS);

      if (continuationItems == null || continuationItems.isEmpty) break;

      final contents = parseFunc(continuationItems);
      if (contents.isEmpty) break;

      items.addAll(contents);
      continuationToken = getContinuationToken(continuationItems);
    } catch (e) {
      break;
    }
  }
  return items;
}

Future<List<dynamic>> getContinuations(
    dynamic results,
    String continuationType,
    int limit,
    Future<dynamic> Function(String additionalParams) requestFunc,
    dynamic Function(Map<String, dynamic> continuationContents) parseFunc,
    {String ctokenPath = "",
    bool reloadable = false,
    String? additionalParams_,
    bool isAdditionparamReturnReq = false}) async {
  List<dynamic> items = [];

  while ((additionalParams_ != null || results.containsKey('continuations')) &&
      (limit > 0 && items.length < limit)) {
    final String additionalParams = additionalParams_ ??
        (reloadable
            ? getReloadableContinuationParams(results)
            : getContinuationParams(results, ctokenPath: ctokenPath));
    //print(additionalParams);

    final Map<String, dynamic> response = await requestFunc(additionalParams);
    //print("Checking........=${response.containsKey('continuationContents')}");
    //inspect(response);
    if (response.containsKey('continuationContents')) {
      results = response['continuationContents'][continuationType];
    } else {
      break;
    }

    final List<dynamic> contents = getContinuationContents(results, parseFunc);
    if (contents.isEmpty) {
      break;
    }
    items.addAll(contents);
  }
  if (isAdditionparamReturnReq) {
    String additionalParam = (reloadable
        ? getReloadableContinuationParams(results)
        : getContinuationParams(results, ctokenPath: ctokenPath));
    return [items, additionalParam];
  } else {
    return items;
  }
}

Future<List<dynamic>> getValidatedContinuations(
    Map<String, dynamic> results,
    String continuationType,
    int limit,
    int perPage,
    Future<dynamic> Function(dynamic additionalParams) requestFunc,
    List<dynamic> Function(Map<String, dynamic> continuationContents) parseFunc,
    {String ctokenPath = ""}) async {
  List<dynamic> items = [];

  while (results.containsKey('continuations') && items.length < limit) {
    final String additionalParams =
        getContinuationParams(results, ctokenPath: ctokenPath);

    final Map<String, dynamic> response =
        await resendRequestUntilParsedResponseIsValid(
            requestFunc,
            additionalParams,
            (response) => getParsedContinuationItems(
                response, parseFunc, continuationType),
            (parsed) => validateResponse(parsed, perPage, limit, items.length),
            3);

    results = response['results'];
    items.addAll(response['parsed']);
  }
  return items;
}

Map<String, dynamic> getParsedContinuationItems(
    Map<String, dynamic> response,
    List<dynamic> Function(Map<String, dynamic> continuationContents) parseFunc,
    String continuationType) {
  Map<String, dynamic> results =
      response['continuationContents'][continuationType];
  return {
    'results': results,
    'parsed': getContinuationContents(results, parseFunc),
  };
}

String getContinuationParams(dynamic results, {String ctokenPath = ''}) {
  final ctoken = nav(results, [
    'continuations',
    0,
    'next${ctokenPath}ContinuationData',
    'continuation'
  ]);
  return getContinuationString(ctoken);
}

String getReloadableContinuationParams(dynamic results) {
  final ctoken = nav(
      results, ['continuations', 0, 'reloadContinuationData', 'continuation']);
  return getContinuationString(ctoken);
}

String getContinuationString(dynamic ctoken) {
  return "&ctoken=$ctoken&continuation=$ctoken";
}

List<dynamic> getContinuationContents(
    Map<String, dynamic> continuation, Function parseFunc) {
  final terms = ['contents', 'items'];
  for (var term in terms) {
    if (continuation.containsKey(term)) {
      return parseFunc(continuation[term]);
    }
  }
  return [];
}

Future<Map<String, dynamic>> resendRequestUntilParsedResponseIsValid(
    Function requestFunc,
    String requestAdditionalParams,
    Function parseFunc,
    Function validateFunc,
    int maxRetries) async {
  var response = await requestFunc(requestAdditionalParams);
  var parsedObject = parseFunc(response);
  int retryCounter = 0;
  while (!validateFunc(parsedObject) && retryCounter < maxRetries) {
    response = await requestFunc(requestAdditionalParams);
    final attempt = parseFunc(response);
    if (attempt['parsed'].length > parsedObject['parsed'].length) {
      parsedObject = attempt;
    }
    retryCounter++;
  }
  return parsedObject;
}

bool validateResponse(
    Map<String, dynamic> response, int perPage, int limit, int currentCount) {
  final remainingItemsCount = limit - currentCount;
  final expectedItemsCount = min(perPage, remainingItemsCount);

  return response['parsed'].length >= expectedItemsCount;
}
