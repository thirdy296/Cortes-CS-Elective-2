import '../models/profile.dart';
import '../supabase_config.dart';

class ProfileService {
  /// The signed-in user's profile and role. RLS lets a customer read only
  /// their own row.
  Future<Profile> fetchMyProfile(String userId) async {
    final row = await supabase
        .from('profiles')
        .select(Profile.selectColumns)
        .eq('id', userId)
        .maybeSingle();
    if (row == null) {
      throw StateError(
        'No profile found for this account. The handle_new_user trigger '
        'may not be installed.',
      );
    }
    return Profile.fromJson(row);
  }
}
