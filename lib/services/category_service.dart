import '../models/category.dart';
import '../supabase_config.dart';
import '../utils/errors.dart';

/// Reads are open to signed-in users; writes are admin-only (RLS).
class CategoryService {
  static const _table = 'categories';

  Future<List<Category>> fetchAll() async {
    final rows = await supabase.from(_table).select('id, name').order('name');
    return rows.map(Category.fromJson).toList();
  }

  Future<void> create(String name) =>
      supabase.from(_table).insert({'name': name});

  Future<void> rename(int id, String name) async => ensureChanged(
    await supabase
        .from(_table)
        .update({'name': name})
        .eq('id', id)
        .select('id'),
  );

  Future<void> delete(int id) async => ensureChanged(
    await supabase.from(_table).delete().eq('id', id).select('id'),
  );
}
