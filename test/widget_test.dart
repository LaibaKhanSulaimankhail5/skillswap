import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/app.dart';

void main() {
  testWidgets('App shows login screen when logged out', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(); // let auth stream settle

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
