import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracking_requests/core/design_system/app_theme.dart';
import 'package:tracking_requests/core/design_system/brand_config.dart';
import 'package:tracking_requests/core/design_system/components/filter_bar.dart';
import 'package:tracking_requests/core/design_system/components/primary_button.dart';
import 'package:tracking_requests/core/design_system/components/status_chip.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_priority_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';
import 'package:tracking_requests/features/requests/presentation/widgets/request_card.dart';

Widget host(Widget child) => MaterialApp(
  theme: AppTheme.fromBrand(const BrandA()),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('StatusChip shows the localized label', (tester) async {
    await tester.pumpWidget(
      host(const StatusChip(RequestStatusEnum.inProgress)),
    );
    expect(find.text('Em andamento'), findsOneWidget);
  });

  testWidgets('PrimaryButton shows a spinner while loading', (tester) async {
    await tester.pumpWidget(
      host(PrimaryButton(label: 'Salvar', isLoading: true, onPressed: () {})),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Salvar'), findsNothing);
  });

  testWidgets('PrimaryButton fires onPressed when enabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(PrimaryButton(label: 'Go', onPressed: () => taps++)),
    );
    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 1);
  });

  testWidgets('FilterBar renders options and reports selection', (
    tester,
  ) async {
    RequestStatusEnum? picked;
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 400,
          child: FilterBar(selected: null, onChanged: (s) => picked = s),
        ),
      ),
    );
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('Aberta'), findsOneWidget);

    await tester.tap(find.text('Aberta'));
    expect(picked, RequestStatusEnum.open);
  });

  testWidgets('RequestCard shows title, meta and status', (tester) async {
    final request = RequestEntity(
      localId: 'l1',
      remoteId: 'r1',
      title: 'Agendar cardiologista',
      description: 'desc',
      category: RequestCategoryEnum.appointment,
      status: RequestStatusEnum.open,
      priority: RequestPriorityEnum.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatusEnum.synced,
    );
    await tester.pumpWidget(
      host(SizedBox(width: 360, child: RequestCard(request: request))),
    );

    expect(find.text('Agendar cardiologista'), findsOneWidget);
    expect(find.text('Consulta · Alta'), findsOneWidget);
    expect(find.text('Aberta'), findsOneWidget);
  });
}
