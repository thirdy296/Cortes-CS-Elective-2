import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import 'state_views.dart';

/// Avatar button: who is signed in, their role, and Sign out.
class AccountMenu extends ConsumerWidget {
  const AccountMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    if (profile == null) return const SizedBox.shrink();
    final name = profile.displayName;

    return PopupMenuButton<String>(
      tooltip: 'Account',
      icon: CircleAvatar(
        radius: 15,
        child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
      ),
      onSelected: (value) async {
        if (value != 'signout') return;
        try {
          await ref.read(authServiceProvider).signOut();
        } catch (e) {
          if (context.mounted) showErrorSnack(context, e);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(name),
            subtitle: Text(
              '${profile.email ?? ''}\n'
              '${profile.isAdmin ? 'Admin' : 'Customer'}',
            ),
            isThreeLine: true,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Sign out'),
          ),
        ),
      ],
    );
  }
}
