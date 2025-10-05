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
  Map<String, List<ResearchPaper>> categorizedPapers = {};
  // Keyword filtering state
  Map<String, int> keywordCounts = {};
  List<String> popularKeywords = [];
  final Set<String> selectedKeywords = {};
  // Precomputed top keywords provided by user (counts and percentage)
  // This will be merged with counts computed from the loaded papers.
  final Map<String, Map<String, dynamic>> precomputedTopKeywords = {
    "space": {"count": 157, "percentage": 4.31},
    "spaceflight": {"count": 98, "percentage": 2.69},
    "cell": {"count": 68, "percentage": 1.87},
    "gene": {"count": 56, "percentage": 1.54},
    "international": {"count": 50, "percentage": 1.37},
    "station": {"count": 50, "percentage": 1.37},
    "mice": {"count": 48, "percentage": 1.32},
    "bone": {"count": 46, "percentage": 1.26},
    "response": {"count": 45, "percentage": 1.24},
    "muscle": {"count": 44, "percentage": 1.21},
    "human": {"count": 36, "percentage": 0.99},
    "expression": {"count": 35, "percentage": 0.96},
    "microgravity": {"count": 33, "percentage": 0.91},
    "arabidopsis": {"count": 32, "percentage": 0.88},
    "effects": {"count": 31, "percentage": 0.85},
    "plant": {"count": 30, "percentage": 0.82},
    "analysis": {"count": 29, "percentage": 0.80},
    "cells": {"count": 27, "percentage": 0.74},
    "radiation": {"count": 27, "percentage": 0.74},
    "mouse": {"count": 26, "percentage": 0.71},
    "skeletal": {"count": 25, "percentage": 0.69},
    "simulated": {"count": 24, "percentage": 0.66},
    "isolated": {"count": 24, "percentage": 0.66},
    "growth": {"count": 23, "percentage": 0.63},
    "changes": {"count": 22, "percentage": 0.60},
    "characterization": {"count": 21, "percentage": 0.58},
    "genome": {"count": 21, "percentage": 0.58},
    "protein": {"count": 20, "percentage": 0.55},
    "stress": {"count": 18, "percentage": 0.49},
    "thaliana": {"count": 16, "percentage": 0.44},
  };
  // Total occurrences from user's stats (used to compute percentages)
  final int totalKeywordOccurrences = 3642;
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController searchController = TextEditingController();
  bool showKeywordRow = false;
  int _currentPage = 0;
  final int _papersPerPage = 30;

  @override
  void initState() {
    super.initState();
    // Keyword row will only be shown when the search icon is explicitly tapped.
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

      // Build categorized map from loaded papers (category may be null)
      final Map<String, List<ResearchPaper>> map = {};
      for (final p in loadedPapers) {
        final key = (p.category != null && p.category!.trim().isNotEmpty)
            ? p.category!
            : 'Uncategorized / Misc';
        map.putIfAbsent(key, () => []).add(p);
      }

      // Build keyword counts and popular keywords (top 30)
      final Map<String, int> kcounts = {};
      for (final p in loadedPapers) {
        for (final kw in p.keywords) {
          final k = kw.toLowerCase().trim();
          if (k.isEmpty) continue;
          kcounts[k] = (kcounts[k] ?? 0) + 1;
        }
      }

      // Merge precomputed top keywords (provided externally). This ensures
      // the top keyword list reflects the user's supplied stats while still
      // counting any other keywords present in the loaded papers.
      precomputedTopKeywords.forEach((k, v) {
        try {
          final providedCount = (v['count'] as num).toInt();
          kcounts[k] = providedCount;
        } catch (_) {
          // ignore malformed entries
        }
      });

      final popular = kcounts.keys.toList()
        ..sort((a, b) => kcounts[b]!.compareTo(kcounts[a]!));
      final topKeywords = popular.take(30).toList();

      setState(() {
        papers = loadedPapers;
        filteredPapers =
            loadedPapers; // Show all papers initially (used for search)
        categorizedPapers = map;
        keywordCounts = kcounts;
        popularKeywords = topKeywords;
        selectedKeywords.clear();
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
    _applyFilters(query);
    _currentPage = 0; // Reset to first page on new search
  }

  void _toggleKeyword(String keyword) {
    final k = keyword.toLowerCase();
    final wasSelected = selectedKeywords.contains(k);
    setState(() {
      if (wasSelected) {
        selectedKeywords.remove(k);
      } else {
        selectedKeywords.add(k);
      }

      // If user just selected a keyword and the search field is empty,
      // populate the search field with that keyword for clarity.
      if (!wasSelected && searchController.text.trim().isEmpty) {
        searchController.text = k;
      }

      // If user just deselected the last keyword and the search field
      // exactly matched that keyword, clear the search field.
      if (wasSelected &&
          selectedKeywords.isEmpty &&
          searchController.text.trim().toLowerCase() == k) {
        searchController.clear();
      }
    });

    _applyFilters(searchController.text);
  }

  void _applyFilters(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      filteredPapers = papers.where((paper) {
        final title = paper.title.toLowerCase();
        final summary = paper.summary.toLowerCase();
        final kws = paper.keywords.map((k) => k.toLowerCase()).toList();

        final matchesSearch =
            q.isEmpty ||
            title.contains(q) ||
            summary.contains(q) ||
            kws.any((keyword) => keyword.contains(q));

        final matchesKeywords =
            selectedKeywords.isEmpty ||
            selectedKeywords.every((sel) => kws.contains(sel));

        return matchesSearch && matchesKeywords;
      }).toList();
    });
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
          // Search Bar with explicit filter icon at the end (always visible)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search papers...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFF00D4FF),
                        ),
                        onPressed: () {
                          setState(() {
                            showKeywordRow = true;
                          });
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                      ),
                      // Keep clear icon when text exists
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF00BFA5),
                              ),
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
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Filters',
                  icon: const Icon(Icons.filter_list, color: Color(0xFF00D4FF)),
                  onPressed: () {
                    setState(() {
                      showKeywordRow = !showKeywordRow;
                    });
                  },
                ),
              ],
            ),
          ),
          // Search Results Info + Keyword filters
          if (showKeywordRow && !isLoading && popularKeywords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
              ),
              child: SizedBox(
                height: 44,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: popularKeywords.map((kw) {
                      final count = keywordCounts[kw] ?? 0;
                      final selected = selectedKeywords.contains(kw);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                kw,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.grey[300],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${count}',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white70
                                      : Colors.grey[400],
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) => _toggleKeyword(kw),
                          selectedColor: const Color(
                            0xFF7C4DFF,
                          ).withOpacity(0.18),
                          backgroundColor: const Color(0xFF3A3C49),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.grey[300],
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          if ((searchController.text.isNotEmpty ||
                  selectedKeywords.isNotEmpty) &&
              !isLoading)
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
          if (searchController.text.isNotEmpty || selectedKeywords.isNotEmpty)
            const SizedBox(height: 8),
          // Content Area
          Expanded(child: _buildContent()),
          if (searchController.text.isNotEmpty || selectedKeywords.isNotEmpty)
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
          if (searchController.text.isEmpty && selectedKeywords.isEmpty)
            Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: TextButton.icon(
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

    // If no active search query, render the categorized view
    if (searchController.text.isEmpty && categorizedPapers.isNotEmpty) {
      final categories = categorizedPapers.keys.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      if (categories.isEmpty) {
        return const Center(
          child: Text(
            'No categories available',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: categories.length,
        itemBuilder: (context, idx) {
          final category = categories[idx];
          final list = categorizedPapers[category] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              elevation: 2,
              child: ExpansionTile(
                initiallyExpanded: false,
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurpleAccent.withOpacity(0.12),
                  child: Text(
                    category.isNotEmpty ? category[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  '${list.length} paper${list.length == 1 ? '' : 's'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                children: list.map((paper) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    title: Text(
                      paper.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      paper.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PaperDetailPage(paper: paper),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
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
