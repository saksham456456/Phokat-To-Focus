import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';
import '../../premium/presentation/paywall_screen.dart';
import '../../focus/providers/focus_provider.dart';
import '../../planner/providers/planner_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Profile Section
              Row(
                children: [
                  const AppLogo(size: 64, showText: false),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          auth.isPremium ? 'Premium Member' : 'Free Tier',
                          style: TextStyle(
                            color: auth.isPremium ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (!auth.isPremium) ...[
                Card(
                  color: Theme.of(context).primaryColor,
                  child: ListTile(
                    leading: const Icon(Icons.workspace_premium, color: Colors.white),
                    title: const Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeProvider.themeMode == ThemeMode.dark ||
                          (themeProvider.themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark),
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  );
                },
              ),
              Consumer<FocusProvider>(
                builder: (context, focus, child) {
                  return SwitchListTile(
                    title: const Text('Strict Focus Mode'),
                    subtitle: const Text('Forcefully block other apps while studying (Android)'),
                    value: focus.isStrictModeEnabled,
                    onChanged: (value) async {
                      await focus.toggleStrictMode(value);
                      if (focus.isStrictModeEnabled && value == true) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Strict Mode Enabled. Do not close the app during focus!')),
                         );
                      }
                    },
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Smart Notifications'),
                subtitle: const Text('Let AI Coach remind you to study'),
                value: auth.isPremium,
                onChanged: (_) {
                  if (!auth.isPremium) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()));
                  }
                },
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                  onPressed: () {
                    auth.logout();
                    Provider.of<PlannerProvider>(context, listen: false).clearData();
                    Provider.of<FocusProvider>(context, listen: false).reset();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Log Out'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
