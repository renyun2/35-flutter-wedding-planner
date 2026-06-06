import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/application/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final wedding = auth?.wedding;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          if (auth != null)
            ListTile(
              title: const Text('当前账号'),
              subtitle: Text('${auth.user.name} (${auth.user.phone})'),
            ),
          if (wedding != null)
            ListTile(
              title: const Text('婚礼档案'),
              subtitle: Text('${wedding.brideName} & ${wedding.groomName}\n绑定码 ${wedding.bindCode ?? '-'}'),
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
