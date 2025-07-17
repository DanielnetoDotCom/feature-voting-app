import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/services/voting_service.dart';

void main() {
  group('VotingService Tests', () {
    late VotingService votingService;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      votingService = VotingService();
    });

    test('should return empty set initially', () async {
      final votedFeatures = await votingService.getVotedFeatures();
      expect(votedFeatures, isEmpty);
    });

    test('should mark feature as voted and retrieve it', () async {
      const featureId = 1;

      // Initially not voted
      expect(await votingService.hasVotedFor(featureId), false);

      // Mark as voted
      await votingService.markAsVoted(featureId);

      // Should now be voted
      expect(await votingService.hasVotedFor(featureId), true);

      // Should be in the voted features set
      final votedFeatures = await votingService.getVotedFeatures();
      expect(votedFeatures, contains(featureId));
    });

    test('should handle multiple votes', () async {
      const featureIds = [1, 2, 3];

      // Mark multiple features as voted
      for (final id in featureIds) {
        await votingService.markAsVoted(id);
      }

      // All should be marked as voted
      for (final id in featureIds) {
        expect(await votingService.hasVotedFor(id), true);
      }

      // Should contain all voted features
      final votedFeatures = await votingService.getVotedFeatures();
      expect(votedFeatures, containsAll(featureIds));
      expect(votedFeatures.length, equals(featureIds.length));
    });

    test('should remove vote correctly', () async {
      const featureId = 1;

      // Mark as voted
      await votingService.markAsVoted(featureId);
      expect(await votingService.hasVotedFor(featureId), true);

      // Remove vote
      await votingService.removeVote(featureId);
      expect(await votingService.hasVotedFor(featureId), false);

      // Should not be in voted features
      final votedFeatures = await votingService.getVotedFeatures();
      expect(votedFeatures, isNot(contains(featureId)));
    });

    test('should clear all votes', () async {
      const featureIds = [1, 2, 3];

      // Mark multiple features as voted
      for (final id in featureIds) {
        await votingService.markAsVoted(id);
      }

      // Clear all votes
      await votingService.clearAllVotes();

      // None should be voted
      for (final id in featureIds) {
        expect(await votingService.hasVotedFor(id), false);
      }

      // Voted features should be empty
      final votedFeatures = await votingService.getVotedFeatures();
      expect(votedFeatures, isEmpty);
    });
  });
}
