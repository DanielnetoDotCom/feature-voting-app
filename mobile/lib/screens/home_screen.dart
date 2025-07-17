import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../services/feature_service.dart';
import '../services/voting_service.dart';
import '../widgets/add_feature_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FeatureService _featureService = FeatureService();
  final VotingService _votingService = VotingService();
  List<Feature> _features = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<int> _votingFeatures =
      {}; // Track which features are currently being voted on
  Set<int> _votedFeatures = {}; // Track which features this device has voted on

  @override
  void initState() {
    super.initState();
    _loadFeatures();
  }

  @override
  void dispose() {
    _featureService.dispose();
    super.dispose();
  }

  Future<void> _loadFeatures() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load both features and voted features in parallel
      final results = await Future.wait([
        _featureService.getFeatures(),
        _votingService.getVotedFeatures(),
      ]);

      final features = results[0] as List<Feature>;
      final votedFeatures = results[1] as Set<int>;

      setState(() {
        _features = features;
        _votedFeatures = votedFeatures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _upvoteFeature(int featureId) async {
    // Check if already voting on this feature
    if (_votingFeatures.contains(featureId)) {
      return;
    }

    // Check if this device has already voted on this feature
    if (_votedFeatures.contains(featureId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already voted for this feature!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _votingFeatures.add(featureId);
    });

    try {
      final updatedFeature = await _featureService.upvoteFeature(featureId);

      // Mark this feature as voted on by this device
      await _votingService.markAsVoted(featureId);

      setState(() {
        final index = _features.indexWhere(
          (feature) => feature.id == featureId,
        );
        if (index != -1) {
          _features[index] = updatedFeature;
        }
        _votedFeatures.add(featureId); // Update local state
        _votingFeatures.remove(featureId);
      });

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote recorded successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _votingFeatures.remove(featureId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addFeature() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddFeatureDialog(),
    );

    if (result != null) {
      try {
        setState(() {
          _isLoading = true;
        });

        final newFeature = await _featureService.createFeature(
          result['title'] as String,
          description: result['description'] as String?,
        );

        setState(() {
          _features.insert(0, newFeature); // Add to beginning of list
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feature created successfully!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create feature: ${e.toString()}'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Voting'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFeatures,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFeature,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Add Feature',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading features...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadFeatures,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_features.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No features available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Pull to refresh or check back later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeatures,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return _buildFeatureCard(feature);
        },
      ),
    );
  }

  Widget _buildFeatureCard(Feature feature) {
    final isVoting = _votingFeatures.contains(feature.id);
    final hasVoted = _votedFeatures.contains(feature.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (feature.description != null &&
                      feature.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      feature.description!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${feature.votes} votes',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      if (hasVoted) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green,
                        ),
                        const Text(
                          'Voted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: (isVoting || hasVoted)
                  ? null
                  : () => _upvoteFeature(feature.id),
              icon: isVoting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(hasVoted ? Icons.check : Icons.thumb_up, size: 16),
              label: Text(
                isVoting
                    ? 'Voting...'
                    : hasVoted
                    ? 'Voted'
                    : 'Upvote',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasVoted ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
