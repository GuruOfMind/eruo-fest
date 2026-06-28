import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/app_settings.dart';
import '../../core/widgets/artist_avatar.dart';
import '../../data/artist_repository.dart';
import '../../data/follows_repository.dart';
import '../../data/seed/european_cities.dart';
import '../../l10n/app_localizations.dart';

/// First-run flow: language → city → pick artists. Each step writes straight to
/// the persisted providers, so progress survives a backgrounded app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _step = 0;
  static const _lastStep = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _lastStep) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      ref.read(appSettingsProvider.notifier).completeOnboarding();
      context.go('/discover');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdvance = _step != 1 ||
        ref.watch(appSettingsProvider).homeCity != null; // city is required

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (_step == _lastStep)
            TextButton(onPressed: _finish, child: Text(l10n.onboardingSkip)),
        ],
      ),
      body: Column(
        children: [
          _StepIndicator(step: _step, count: _lastStep + 1),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _step = i),
              children: const [
                _LanguageStep(),
                _CityStep(),
                _ArtistsStep(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: canAdvance ? _next : null,
              child: Text(
                _step == _lastStep
                    ? l10n.onboardingGetStarted
                    : l10n.onboardingContinue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    ref.read(appSettingsProvider.notifier).completeOnboarding();
    context.go('/discover');
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.count});
  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(count, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsetsDirectional.only(end: 6),
              decoration: BoxDecoration(
                color: active ? scheme.primary : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LanguageStep extends ConsumerWidget {
  const _LanguageStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return _StepBody(
      title: l10n.onboardingWelcomeTitle,
      subtitle: l10n.onboardingWelcomeBody,
      child: Column(
        children: [
          Text(l10n.onboardingChooseLanguage,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: settings.locale.languageCode,
            onChanged: (v) => notifier.setLocale(Locale(v!)),
            child: Column(
              children: [
                for (final code in const ['ar', 'en'])
                  RadioListTile<String>(
                    value: code,
                    title: Text(
                      code == 'ar' ? l10n.languageArabic : l10n.languageEnglish,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CityStep extends ConsumerWidget {
  const _CityStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final selected = ref.watch(appSettingsProvider).homeCity;
    final notifier = ref.read(appSettingsProvider.notifier);

    return _StepBody(
      title: l10n.onboardingChooseCity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final city in kEuropeanCities)
            ChoiceChip(
              label: Text(city.displayName(lang)),
              selected: selected == city.id,
              onSelected: (_) => notifier.setHomeCity(city.id),
            ),
        ],
      ),
    );
  }
}

class _ArtistsStep extends ConsumerWidget {
  const _ArtistsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = ref.watch(appSettingsProvider).locale.languageCode;
    final artists = ref.watch(artistRepositoryProvider).all();
    final follows = ref.watch(followsProvider);
    final notifier = ref.read(followsProvider.notifier);

    return _StepBody(
      title: l10n.onboardingChooseArtists,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final artist in artists)
            FilterChip(
              avatar: ArtistAvatar(artist: artist, radius: 12),
              label: Text(artist.displayName(lang)),
              selected: follows.contains(artist.id),
              onSelected: (_) => notifier.toggle(artist.id),
            ),
        ],
      ),
    );
  }
}

/// Shared scrollable layout for an onboarding step.
class _StepBody extends StatelessWidget {
  const _StepBody({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: text.bodyMedium),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
