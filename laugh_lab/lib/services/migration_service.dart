import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/remix_model.dart';
import 'package:laugh_lab/services/user_service.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService;
  
  MigrationService(this._userService);
  
  // Update all existing remixes to include username data from user accounts
  Future<void> updateRemixesWithUsernames() async {
    try {
      // Get all remixes
      final remixesSnapshot = await _firestore
          .collection(AppConstants.remixesCollection)
          .get();
      
      if (remixesSnapshot.docs.isEmpty) {
        debugPrint('No remixes found to update');
        return;
      }
      
      debugPrint('Found ${remixesSnapshot.docs.length} remixes to process');
      
      // Process each remix
      for (final doc in remixesSnapshot.docs) {
        try {
          final remix = RemixModel.fromMap(doc.data());
          
          // Get user data for this remix
          final userData = await _userService.getUserById(remix.userId);
          
          if (userData != null) {
            // Prepare update data
            final Map<String, dynamic> updateData = {};
            
            // Update username if available
            if (userData.username != null && 
                (remix.username == null || remix.username != userData.username)) {
              updateData['username'] = userData.username;
              debugPrint('Will update remix ${remix.id} with username ${userData.username}');
            }
            
            // Update display name if it's Anonymous or null
            if (userData.displayName != null && 
                (remix.userDisplayName == null || 
                 remix.userDisplayName == 'Anonymous')) {
              updateData['userDisplayName'] = userData.displayName;
              debugPrint('Will update remix ${remix.id} with displayName ${userData.displayName}');
            }
            
            // Only update if there are changes
            if (updateData.isNotEmpty) {
              await _firestore
                  .collection(AppConstants.remixesCollection)
                  .doc(remix.id)
                  .update(updateData);
                  
              debugPrint('Updated remix ${remix.id} with data: $updateData');
            }
          }
        } catch (e) {
          debugPrint('Error updating remix ${doc.id}: $e');
          // Continue with next remix even if one fails
          continue;
        }
      }
      
      debugPrint('Completed remix username and display name migration');
    } catch (e) {
      debugPrint('Error in migration: $e');
      rethrow;
    }
  }
} 