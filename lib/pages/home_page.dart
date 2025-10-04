import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  int _currentPage = 0;
  final int _papersPerPage = 30;

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

  int get _currentStartIndex => _currentPage * _papersPerPage;

  int get _currentEndIndex =>
      (_currentPage + 1) * _papersPerPage < filteredPapers.length
      ? (_currentPage + 1) * _papersPerPage
      : filteredPapers.length;

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
    _currentPage = 0; // Reset to first page on new search
  }

  Future<void> _launchGitHub() async {
    final Uri url = Uri.parse('https://github.com/MAyman007/AstroLens');
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open GitHub repository')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open GitHub repository')),
        );
      }
    }
  }

  Future<void> _launchReleases() async {
    final Uri url = Uri.parse(
      'https://github.com/MAyman007/AstroLens/releases',
    );
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (launched == false && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open releases page')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open releases page')));
      }
    }
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
          if (kIsWeb)
            TextButton.icon(
              onPressed: _launchReleases,
              icon: const Icon(
                Icons.download,
                color: Color(0xFF00BFA5),
                size: 18,
              ),
              label: const Text(
                'Download App',
                style: TextStyle(
                  color: Color(0xFF00BFA5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton.icon(
            onPressed: _launchGitHub,
            icon: const Icon(Icons.code, color: Color(0xFF00BFA5)),
            label: const Text(
              'Source Code',
              style: TextStyle(
                color: Color(0xFF00BFA5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Additional futuristic element
          // Container(
          //   margin: const EdgeInsets.only(right: 16.0),
          //   child: const Icon(
          //     Icons.science,
          //     color: Color(0xFF7C4DFF), // Electric Purple
          //   ),
          // ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
              ),
              Text(
                'Page ${_currentPage + 1} of ${((filteredPapers.length + _papersPerPage - 1) / _papersPerPage).floor()}',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _currentEndIndex < filteredPapers.length
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 30),
        child: FloatingActionButton.extended(
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
      itemCount: _currentEndIndex - _currentStartIndex,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final paper = filteredPapers[index + _currentStartIndex];
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
