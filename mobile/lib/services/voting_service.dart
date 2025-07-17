import 'package:shared_preferences/shared_preferences.dart';

class VotingService {
  static const String _votedFeaturesKey = 'voted_features';

  // Get the list of feature IDs that this device has voted on
  Future<Set<int>> getVotedFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    final votedFeaturesStrings = prefs.getStringList(_votedFeaturesKey) ?? [];
    return votedFeaturesStrings.map((id) => int.parse(id)).toSet();
  }

  // Check if this device has already voted on a specific feature
  Future<bool> hasVotedFor(int featureId) async {
    final votedFeatures = await getVotedFeatures();
    return votedFeatures.contains(featureId);
  }

  // Mark a feature as voted on by this device
  Future<void> markAsVoted(int featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final votedFeatures = await getVotedFeatures();
    votedFeatures.add(featureId);

    final votedFeaturesStrings = votedFeatures
        .map((id) => id.toString())
        .toList();
    await prefs.setStringList(_votedFeaturesKey, votedFeaturesStrings);
  }

  // Remove a vote (for testing purposes or if vote needs to be undone)
  Future<void> removeVote(int featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final votedFeatures = await getVotedFeatures();
    votedFeatures.remove(featureId);

    final votedFeaturesStrings = votedFeatures
        .map((id) => id.toString())
        .toList();
    await prefs.setStringList(_votedFeaturesKey, votedFeaturesStrings);
  }

  // Clear all votes (for testing purposes)
  Future<void> clearAllVotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_votedFeaturesKey);
  }
}
