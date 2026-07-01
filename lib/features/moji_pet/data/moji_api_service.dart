import '../domain/moji_action.dart';
import 'moji_api_models.dart';

class MojiApiService {
  const MojiApiService();

  MojiApiResponse handle(MojiApiRequest request) {
    switch (request.type) {
      case 'time':
        return MojiApiResponse(
          type: 'time_rsp',
          data: <String, Object?>{
            'time': DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
            'offset': DateTime.now().timeZoneOffset.inSeconds,
          },
        );
      case 'token_req':
        return const MojiApiResponse(
          type: 'token_rsp',
          data: <String, Object?>{'result': 1, 'mode': 'local'},
        );
      case 'sta_req':
        return _status(request.data['request']);
      case 'anim_req':
        return _animation(request.data);
      case 'tts_req':
        return MojiApiResponse(
          type: 'tts_rsp',
          data: <String, Object?>{
            'result': 1,
            'text': request.data['text']?.toString() ?? '',
            'format': 'flutter_tts',
            'sampleRate': 24000,
          },
        );
      case 'emo_event':
        final action = parseAction(request.data['action']?.toString());
        final profile = action.profile;
        return MojiApiResponse(
          type: 'emo_event_rsp',
          data: <String, Object?>{
            'result': 1,
            'action': action.name,
            'label': profile.label,
            'mood': profile.mood.name,
            'animation': profile.animation.name,
            'message': profile.message,
          },
        );
      default:
        return MojiApiResponse(
          type: 'error_rsp',
          data: <String, Object?>{'result': 0, 'error': 'unknown_type', 'type': request.type},
        );
    }
  }

  MojiApiResponse _status(Object? requested) {
    final id = requested is List && requested.isNotEmpty ? requested.first : requested;
    switch (id) {
      case 0:
        return const MojiApiResponse(type: 'sta_rsp', data: <String, Object?>{'device': <String, Object?>{'device_id': 'moji-local'}});
      case 1:
        return const MojiApiResponse(type: 'sta_rsp', data: <String, Object?>{'version': <String, Object?>{'number': 1, 'name': '0.1.0'}});
      case 11:
        return const MojiApiResponse(type: 'sta_rsp', data: <String, Object?>{'personality': <String, Object?>{'name': 'MOJI', 'age': 1, 'color': 'purple', 'sign': 'virtual'}});
      case 12:
        return const MojiApiResponse(type: 'sta_rsp', data: <String, Object?>{'preference': <String, Object?>{'volume': 1, 'auto_update': 0, 'schedule_sound': 1}});
      default:
        return const MojiApiResponse(type: 'sta_rsp', data: <String, Object?>{});
    }
  }

  MojiApiResponse _animation(Map<String, Object?> data) {
    final op = data['op']?.toString() ?? 'play';
    final name = data['name']?.toString() ?? 'neutral';
    return MojiApiResponse(
      type: 'anim_rsp',
      data: <String, Object?>{'result': 1, 'op': op, 'name': name},
    );
  }

  MojiAction parseAction(String? raw) {
    if (raw == null || raw.isEmpty) return MojiAction.staying;
    return MojiAction.values.firstWhere(
      (action) => action.name == raw,
      orElse: () => MojiAction.staying,
    );
  }

  List<MojiApiEvent> knownEvents() {
    return MojiAction.values.map((action) {
      final profile = action.profile;
      return MojiApiEvent(
        code: action.name,
        action: action,
        label: profile.label,
        message: profile.message,
      );
    }).toList(growable: false);
  }
}
