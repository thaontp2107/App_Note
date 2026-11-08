import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:note_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Thêm, sửa và xóa ghi chú', (tester) async {
    await tester.pumpWidget(const NoteApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Chưa có ghi chú nào'), findsOneWidget);

    // Thêm
    await tester.tap(find.text('Thêm ghi chú'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('titleField')), 'Mua sắm');
    await tester.enterText(
      find.byKey(const Key('contentField')),
      'Sữa, bánh mì',
    );
    await tester.tap(find.byTooltip('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Mua sắm'), findsOneWidget);
    expect(find.text('Sữa, bánh mì'), findsOneWidget);

    // Sửa
    await tester.tap(find.text('Mua sắm'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('titleField')), 'Đi chợ');
    await tester.tap(find.byTooltip('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Đi chợ'), findsOneWidget);
    expect(find.text('Mua sắm'), findsNothing);

    // Xóa
    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Đi chợ'), findsNothing);
    expect(find.textContaining('Chưa có ghi chú nào'), findsOneWidget);
  });
}
