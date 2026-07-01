import 'package:flutter_test/flutter_test.dart';
import 'package:moji_pet/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MOJI app renders the home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MojiApp());
    await tester.pump();

    expect(find.text('MOJI'), findsOneWidget);
    expect(find.textContaining('Humor:'), findsOneWidget);
  });
}
