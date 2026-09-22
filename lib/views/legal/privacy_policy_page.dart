import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../../widgets/reusable_widgets.dart';

/// Static in-app privacy policy.
///
/// TODO(production): also publish this same text on a page you host, and put
/// that URL in the Play Console / App Store Connect privacy policy field --
/// both stores require a public URL, an in-app screen alone isn't enough.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _lastUpdated = 'September 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Text('Privacy Policy', style: AppTheme.display(20)),
                ],
              ),
            ),
            const GoldDivider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  Text(
                    'Last updated: $_lastUpdated',
                    style: AppTheme.label(12, color: AppTheme.textDim),
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Overview',
                    body:
                        'Holy Bible ("the app") is a Bible reading app. This '
                        'policy explains what information the app and its '
                        'third-party services collect and how it is used. '
                        'The app does not require an account and does not '
                        'collect your name, email, or any personal contact '
                        'information.',
                  ),
                  _Section(
                    title: 'Information stored on your device',
                    body:
                        'Your bookmarks, last-read position, and font size '
                        'preference are stored locally on your device using '
                        'standard app storage. This data is never sent to '
                        'us and is deleted if you uninstall the app.',
                  ),
                  _Section(
                    title: 'Advertising',
                    body:
                        'The app shows ads served by Google AdMob (Google '
                        'Mobile Ads SDK). Google and its advertising '
                        'partners may collect device identifiers (such as '
                        'your advertising ID), approximate location, and '
                        'other data to serve and measure ads, which may '
                        'include personalized ads where you have consented. '
                        'On iOS, the app asks for App Tracking Transparency '
                        'permission before any such identifier is used for '
                        'tracking. You can review or withdraw ad consent at '
                        'any time from the privacy icon on the Home screen. '
                        'See Google\'s privacy policy for details on how '
                        'Google handles this data: '
                        'https://policies.google.com/privacy',
                  ),
                  _Section(
                    title: 'Children\'s privacy',
                    body:
                        'The app is not directed at children under 13 and '
                        'does not knowingly collect personal information '
                        'from children.',
                  ),
                  _Section(
                    title: 'Data sharing',
                    body:
                        'We do not sell your data. We do not operate any '
                        'servers or backend for this app -- the only data '
                        'leaving your device is what Google AdMob collects '
                        'as described above.',
                  ),
                  _Section(
                    title: 'Changes to this policy',
                    body:
                        'If this policy changes, the "Last updated" date '
                        'above will be revised and the new version will '
                        'ship with the next app update.',
                  ),
                  _Section(
                    title: 'Contact',
                    body:
                        // TODO(production): replace with a real support
                        // contact before release.
                        'Questions about this policy can be sent to '
                        '[add your contact email here].',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.display(16, color: AppTheme.gold)),
          const SizedBox(height: 8),
          Text(body, style: AppTheme.body(14, color: AppTheme.parchment)),
        ],
      ),
    );
  }
}
