import 'package:flutter/material.dart';
import '../models/research_paper.dart';
import '../services/paper_service.dart';
import 'paper_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ResearchPaper> papers = [];
  List<ResearchPaper> filteredPapers = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPapers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPapers() async {
    try {
      final loadedPapers = await PaperService.loadPapers();
      setState(() {
        papers = loadedPapers;
        filteredPapers = loadedPapers; // Show all papers initially
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load papers: $e';
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPapers = papers;
      } else {
        final searchQuery = query.toLowerCase().trim();
        filteredPapers = papers
            .where(
              (paper) =>
                  paper.title.toLowerCase().contains(searchQuery) ||
                  paper.summary.toLowerCase().contains(searchQuery) ||
                  paper.keywords.any(
                    (keyword) => keyword.toLowerCase().contains(searchQuery),
                  ),
            )
            .toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      filteredPapers = papers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astro Rush'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search papers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // Search Results Info
          if (searchController.text.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Found ${filteredPapers.length} paper${filteredPapers.length == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (filteredPapers.length != papers.length)
                    Text(
                      ' out of ${papers.length}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                ],
              ),
            ),
          if (searchController.text.isNotEmpty && !isLoading)
            const SizedBox(height: 8),
          // Content Area
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
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

    if (filteredPapers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No papers found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPapers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final paper = filteredPapers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              paper.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  paper.summary,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4.0,
                  children: paper.keywords
                      .take(3) // Show only first 3 keywords
                      .map(
                        (keyword) => Chip(
                          label: Text(
                            keyword,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          side: BorderSide.none,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaperDetailPage(paper: paper),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showPaperDetails(ResearchPaper paper) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(paper.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(paper.summary, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Text(
                  'Keywords:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                const SizedBox(height: 16),
                const Text(
                  'Link:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // Here you could open the link in a browser
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Link: ${paper.link}')),
                    );
                  },
                  child: Text(
                    paper.link,
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
