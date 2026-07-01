import 'package:flutter_test/flutter_test.dart';
import 'package:moji_pet/main.dart';

void main() {
  testWidgets('MOJI app renders the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MojiApp());

    expect(find.text('MOJI'), findsOneWidget);
    expect(find.textContaining('Pet virtual'), findsOneWidget);
  });
}
