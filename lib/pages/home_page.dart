import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/research_paper.dart';
import '../services/paper_service.dart';
import 'paper_detail_page.dart';
import 'chat_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Futuristic logo icon
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Astro Rush text with futuristic styling
            Text(
              'ASTRO',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00D4FF), // Cosmic Blue
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'LENS',
              style: GoogleFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00BFA5), // Emerald Teal
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          // Additional futuristic element
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: const Icon(
              Icons.science,
              color: Color(0xFF7C4DFF), // Electric Purple
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search papers...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00D4FF)),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF00BFA5)),
                        onPressed: () {
                          searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color(0xFF3D4354)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF3D4354),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF00D4FF),
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: const Color(0xFF242938),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ChatPage()));
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Ask Assistant'),
        elevation: 8,
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
                          backgroundColor: const Color(
                            0xFF7C4DFF,
                          ).withOpacity(0.15),
                          side: BorderSide(
                            color: const Color(0xFF7C4DFF).withOpacity(0.3),
                          ),
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
}
