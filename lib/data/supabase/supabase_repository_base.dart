import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_mappers.dart';

abstract class SupabaseRepositoryBase {
  const SupabaseRepositoryBase(this.client);

  final SupabaseClient client;

  User get currentUser {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('A signed-in Supabase user is required.');
    }
    return user;
  }

  String get currentUserId => currentUser.id;

  SupabaseQueryBuilder table(String tableName) => client.from(tableName);

  SupabaseRow withCurrentUserId(SupabaseRow payload) => {
        ...payload,
        'user_id': currentUserId,
      };

  SupabaseRow softDeletePayload({DateTime? deletedAt}) => {
        'deleted_at': (deletedAt ?? DateTime.now()).toIso8601String(),
      };

  Stream<List<T>> watchByPolling<T>(
    Future<List<T>> Function() fetch, {
    Duration interval = const Duration(seconds: 2),
  }) async* {
    while (true) {
      yield await fetch();
      await Future<void>.delayed(interval);
    }
  }
}
