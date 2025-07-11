import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuncforwork/views/widgets/notification_alert_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  group('Bildirim Widget Testleri', () {
    testWidgets('Bildirim gösterme testi', (tester) async {
      const testNotification = {
        'title': 'Yeni Etkinlik',
        'body': 'Flutter Meetup etkinliği oluşturuldu!',
      };

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (_) => NotificationAlertDialog(
                        title: testNotification['title'] as String,
                        message: testNotification['body'] as String,
                        onTap: () {},
                      ),
                    );
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NotificationAlertDialog), findsOneWidget);
      expect(find.text('Yeni Etkinlik'), findsOneWidget);
      expect(
        find.text('Flutter Meetup etkinliği oluşturuldu!'),
        findsOneWidget,
      );

      await tester.tap(find.text('Kapat'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationAlertDialog), findsNothing);
    });

    testWidgets('Bildirim etkileşim testi', (tester) async {
      bool notificationTapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: NotificationAlertDialog(
              title: 'Test Bildirimi',
              message: 'Test mesajı',
              onTap: () {
                notificationTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Görüntüle'));
      await tester.pumpAndSettle();

      expect(notificationTapped, true);
    });

    testWidgets('Bildirim izinleri testi', (tester) async {
      bool permissionRequested = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  permissionRequested = true;
                },
                child: const Text('Bildirim İzni İste'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bildirim İzni İste'));
      await tester.pumpAndSettle();

      expect(permissionRequested, true);
    });
  });
}
