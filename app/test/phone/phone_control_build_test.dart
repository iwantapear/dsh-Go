import 'package:dsh_app/diagnostics/diagnostics_bundle.dart';
import 'package:dsh_app/links/launcher_entries.dart';
import 'package:dsh_app/links/page_links.dart';
import 'package:dsh_app/phone/build_flag.dart';
import 'package:dsh_app/phone/phone_channel.dart';
import 'package:dsh_app/runtime/runtime_bridge.dart';
import 'package:dsh_app/state/access_state.dart';
import 'package:dsh_app/state/settings_state.dart';
import 'package:dsh_app/ui/features/feature_catalog.dart';
import 'package:dsh_app/ui/settings/index/settings_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('phone-control build entries', () {
    test('catalog, settings search, and deep links follow the build flag', () {
      final items = [for (final section in featureSections) ...section.items];
      expect(items.any((item) => item.id == 'phone'), phoneControlBuildEnabled);
      expect(
        SettingsIndex.spots.any((spot) => spot.id == 'page:phone'),
        phoneControlBuildEnabled,
      );
      expect(
        SettingsIndex.spots.any(
          (spot) => spot.id == 'permission-phone-confirm',
        ),
        phoneControlBuildEnabled,
      );
      expect(SettingsIndex.linkIds.contains('phone'), phoneControlBuildEnabled);
      expect(
        SettingsIndex.linkIds.contains('phone-confirm'),
        phoneControlBuildEnabled,
      );
      expect(
        pageLinkId(Uri.parse('dshgo://open/phone')),
        phoneControlBuildEnabled ? 'phone' : null,
      );
      expect(settingsPageForLink('phone') == null, !phoneControlBuildEnabled);

      // Unrelated phone-named settings remain available in either build.
      expect(SettingsIndex.linkIds, contains('phone-files'));
      expect(
        SettingsIndex.spot(Spots.webPhoneLayout.id),
        same(Spots.webPhoneLayout),
      );
    });

    test('restored access choices drop only phone control', () {
      final features = sanitizeAccessFeatures(AccessFeature.values);
      expect(features.contains(AccessFeature.phone), phoneControlBuildEnabled);
      expect(
        features.containsAll({
          AccessFeature.files,
          AccessFeature.pet,
          AccessFeature.background,
          AccessFeature.voice,
        }),
        isTrue,
      );
      expect(
        accessItemsFor(AccessFeature.phone, null).isEmpty,
        !phoneControlBuildEnabled,
      );
      expect(accessItemsFor(AccessFeature.files, null), [AccessItem.storage]);
      expect(accessItemsFor(AccessFeature.pet, null), [AccessItem.overlay]);
    });

    test('pet screenshots are ignored without phone control, other shortcuts remain', () {
      final screenshot = LauncherEntry.parse({
        'kind': 'screenshot',
        'path': '/cache/pet-screenshots/slot/screen.png',
      });
      expect(screenshot is ScreenshotEntry, phoneControlBuildEnabled);
      expect(LauncherEntry.parse({'kind': 'new'}), isA<NewChatEntry>());
    });

    test(
      'diagnostics omit the phone snapshot in a phone-control-free build',
      () {
        final snapshot = DiagnosticsSnapshot(
          at: DateTime.utc(2026, 11, 10),
          status: const RuntimeStatus.unknown(),
          settings: const AppSettings(),
          phone: const PhoneStatus(enabled: true),
        );
        final summary = DiagnosticsBundle.summary(snapshot);
        expect(summary.containsKey('phone'), phoneControlBuildEnabled);
        if (phoneControlBuildEnabled) {
          expect((summary['phone']! as Map)['enabled'], isTrue);
        }
      },
    );
  });
}
