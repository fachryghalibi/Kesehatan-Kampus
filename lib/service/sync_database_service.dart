// lib/services/sync_database_service.dart

import 'package:http/http.dart' as http;

class SyncDatabaseService {
  Future<bool> syncUsers() async {
    const url = 'https://backendtelkommedikamobile.se4603.my.id/sync_user_db.php'; 

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print("Sync successful!");
        return true;  // Successfully synced
      } else {
        print("Sync failed. Status code: ${response.statusCode}");
        return false;  // Failed to sync
      }
    } catch (e) {
      print("Error syncing databases: $e");
      return false;  // Error occurred
    }
  }
}
