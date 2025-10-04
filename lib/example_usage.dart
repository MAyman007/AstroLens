import 'package:flutter/material.dart';
import 'services/paper_service.dart';
import 'models/research_paper.dart';

/// Example widget demonstrating how to use the loadPapers() function
class PapersListWidget extends StatefulWidget {
  const PapersListWidget({super.key});

  @override
  State<PapersListWidget> createState() => _PapersListWidgetState();
}

class _PapersListWidgetState extends State<PapersListWidget> {
  List<ResearchPaper>? papers;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPapers();
  }

  Future<void> _loadPapers() async {
    try {
      // Example 1: Using the class method
      final loadedPapers = await PaperService.loadPapers();

      // Example 2: Alternative using standalone function
      // final loadedPapers = await loadPapers();

      setState(() {
        papers = loadedPapers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load papers: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadPapers();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (papers == null || papers!.isEmpty) {
      return const Center(child: Text('No papers found'));
    }

    return ListView.builder(
      itemCount: papers!.length,
      itemBuilder: (context, index) {
        final paper = papers![index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paper.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  paper.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4.0,
                  children: paper.keywords
                      .map(
                        (keyword) => Chip(
                          label: Text(keyword),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    // Here you could open the link in a browser
                    // For example: launch(paper.link);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link: ${paper.link}')),
                    );
                  },
                  child: Text(
                    'View Paper',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Simple example of how to use the loadPapers function
void exampleUsage() async {
  try {
    // Method 1: Using PaperService class
    List<ResearchPaper> papers = await PaperService.loadPapers();
    print('Loaded ${papers.length} papers');

    for (ResearchPaper paper in papers) {
      print('Paper: ${paper.title}');
      print('Keywords: ${paper.keywords.join(', ')}');
      print('---');
    }

    // Method 2: Using standalone function
    List<ResearchPaper> papersAlt = await loadPapers();
    print('Alternative method loaded ${papersAlt.length} papers');

    // Method 3: Using alternative class method
    List<ResearchPaper> papersFromAssets =
        await PaperService.getPapersFromAssets();
    print('From assets method loaded ${papersFromAssets.length} papers');
  } catch (e) {
    print('Error loading papers: $e');
  }
}
