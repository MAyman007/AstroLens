import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/research_paper.dart';
import '../services/paper_service.dart';

class PaperDetailPage extends StatefulWidget {
  final ResearchPaper paper;

  const PaperDetailPage({super.key, required this.paper});

  @override
  State<PaperDetailPage> createState() => _PaperDetailPageState();
}

class _PaperDetailPageState extends State<PaperDetailPage> {
  bool _showFullArticle = false;
  ResearchPaper? _apiPaper;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPaperFromApi();
  }

  Future<void> _fetchPaperFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiPaper = await PaperService.fetchPaperFromApi(widget.paper.link);
      setState(() {
        _apiPaper = apiPaper;
        _isLoading = false;
      });
    } catch (e) {
      print('API call failed: $e');
      setState(() {
        _errorMessage =
            'API temporarily unavailable. Showing paper summary instead.';
        _isLoading = false;
      });
      // Don't show error for long - just silently use the original paper data
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    }
  }

  ResearchPaper get _currentPaper => _apiPaper ?? widget.paper;

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(widget.paper.link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch ${widget.paper.link}');
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Error loading paper details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _fetchPaperFromApi,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentToggle() {
    if (_apiPaper == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SwitchListTile(
              title: Text(
                _showFullArticle ? 'Full Article' : 'AI Summary',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                _showFullArticle
                    ? 'Complete research paper sections'
                    : 'Simplified AI-generated summary',
              ),
              value: _showFullArticle,
              onChanged: (value) {
                setState(() {
                  _showFullArticle = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Only show content if API data is available
    if (_apiPaper == null) return const SizedBox.shrink();

    final content = _showFullArticle
        ? _apiPaper!.fullArticle
        : _apiPaper!.simplifiedAiVersion;
    final title = _showFullArticle ? 'Full Article' : 'AI Summary';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _showFullArticle ? Icons.article : Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paper Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Paper Title
            Text(
              _currentPaper.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Original Summary as Subtitle
            Text(
              widget.paper.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Loading indicator
            if (_isLoading) _buildLoadingIndicator(),

            // Error message
            if (_errorMessage != null) ...[
              _buildErrorMessage(),
              const SizedBox(height: 24),
            ],

            // Content toggle (only show if API data is available)
            _buildContentToggle(),
            const SizedBox(height: 16),

            // Main content
            _buildContent(),
            const SizedBox(height: 24),

            // Keywords Section (only show if available)
            if (_currentPaper.keywords.isNotEmpty) ...[
              Text(
                'Keywords',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _currentPaper.keywords
                    .map(
                      (keyword) => Chip(
                        label: Text(
                          keyword,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Read Full Paper Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchUrl,
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Read Original Paper',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
