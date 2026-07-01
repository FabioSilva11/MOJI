import '../domain/moji_action.dart';

class MojiApiResponse {
  const MojiApiResponse({required this.type, required this.data});

  final String type;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'data': data,
      };
}

class MojiApiRequest {
  const MojiApiRequest({required this.type, this.data = const <String, Object?>{}});

  final String type;
  final Map<String, Object?> data;

  factory MojiApiRequest.fromJson(Map<String, Object?> json) {
    final rawData = json['data'];
    return MojiApiRequest(
      type: json['type']?.toString() ?? '',
      data: rawData is Map ? Map<String, Object?>.from(rawData) : const <String, Object?>{},
    );
  }
}

class MojiApiEvent {
  const MojiApiEvent({
    required this.code,
    required this.action,
    required this.label,
    required this.message,
  });

  final String code;
  final MojiAction action;
  final String label;
  final String message;

  Map<String, Object?> toJson() => <String, Object?>{
        'code': code,
        'action': action.name,
        'label': label,
        'message': message,
      };
}
