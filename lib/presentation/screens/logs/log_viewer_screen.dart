import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

/// How many lines to load per page when viewing a large file.
const int _kLinesPerPage = 200;

/// Files larger than this (bytes) use chunked/paginated reading.
const int _kChunkedThreshold = 512 * 1024; // 512 KB

/// Top-level function for [Isolate.run] — must be top-level (not a closure
/// or instance method) so the isolate message passing only carries a plain
/// [String], which is always sendable across isolate boundaries.
List<String> _readLinesSync(String path) => File(path).readAsLinesSync();

// ─── Screen ────────────────────────────────────────────────────────────────

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  Map<String, List<File>> _logFilesByDate = {};
  bool _isLoading = true;
  String? _expandedDate;

  // Viewer state
  File? _viewingFile;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  // ─── Data Loading ─────────────────────────────────────────────────────

  Future<void> _loadLogFiles() async {
    setState(() => _isLoading = true);
    try {
      _logFilesByDate = await WiseLogger.getLogFilesByDate();
      if (_logFilesByDate.isNotEmpty && _expandedDate == null) {
        _expandedDate = _logFilesByDate.keys.first;
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to load log files',
          type: SnackBarMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────

  void _viewFile(File file) {
    setState(() => _viewingFile = file);
  }

  void _closeViewer() {
    setState(() => _viewingFile = null);
  }

  Future<void> _shareFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'WiseSpends Log - $fileName',
        ),
      );
      if (mounted) {
        showSnackBarMessage(
          context,
          result.status == ShareResultStatus.success
              ? 'Log file shared successfully'
              : 'Share cancelled',
          type: result.status == ShareResultStatus.success
              ? SnackBarMessageType.success
              : SnackBarMessageType.info,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to share log file',
          type: SnackBarMessageType.error,
        );
      }
    }
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete Log File',
      message: 'Are you sure you want to delete this log file?',
      deleteText: 'Delete',
      autoDisplayMessage: false,
    );
    if (confirmed != true) return;

    try {
      await WiseLogger.deleteLogFile(file);
      if (mounted) {
        showSnackBarMessage(
          context,
          'Log file deleted',
          type: SnackBarMessageType.success,
        );
        _closeViewer();
        await _loadLogFiles();
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to delete log file',
          type: SnackBarMessageType.error,
        );
      }
    }
  }

  Future<void> _deleteDate(String date) async {
    final confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete Logs for $date',
      message: 'Delete all log files for this date?',
      deleteText: 'Delete All',
      autoDisplayMessage: false,
    );
    if (confirmed != true) return;

    try {
      final deleted = await WiseLogger.deleteLogsByDate(date);
      if (mounted) {
        showSnackBarMessage(
          context,
          'Deleted $deleted log file(s)',
          type: SnackBarMessageType.success,
        );
        await _loadLogFiles();
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to delete log files',
          type: SnackBarMessageType.error,
        );
      }
    }
  }

  Future<void> _deleteAllLogs() async {
    final confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete All Logs',
      message: 'Delete ALL log files? This cannot be undone.',
      deleteText: 'Delete All',
      autoDisplayMessage: false,
    );
    if (confirmed != true) return;

    try {
      final deleted = await WiseLogger.deleteAllLogs();
      if (mounted) {
        showSnackBarMessage(
          context,
          'Deleted $deleted log file(s)',
          type: SnackBarMessageType.success,
        );
        await _loadLogFiles();
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to delete log files',
          type: SnackBarMessageType.error,
        );
      }
    }
  }

  Future<void> _shareAllLogs() async {
    try {
      final allFiles = await WiseLogger.getAllLogFiles();
      if (allFiles.isEmpty) {
        if (mounted) {
          showSnackBarMessage(
            context,
            'No log files to share',
            type: SnackBarMessageType.info,
          );
        }
        return;
      }
      final xFiles = allFiles.map((f) => XFile(f.path)).toList();
      final result = await SharePlus.instance.share(
        ShareParams(files: xFiles, subject: 'WiseSpends Logs - All Files'),
      );
      if (mounted) {
        showSnackBarMessage(
          context,
          result.status == ShareResultStatus.success
              ? 'Shared ${xFiles.length} log file(s)'
              : 'Share cancelled',
          type: result.status == ShareResultStatus.success
              ? SnackBarMessageType.success
              : SnackBarMessageType.info,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to share log files',
          type: SnackBarMessageType.error,
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Push viewer as a nested Navigator-like widget so we keep the parent
    // AppBar accessible for back navigation without a full route push.
    if (_viewingFile != null) {
      return _LogFileViewer(
        file: _viewingFile!,
        onClose: _closeViewer,
        onShare: () => _shareFile(_viewingFile!),
        onDelete: () => _deleteFile(_viewingFile!),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('App Logs'),
        centerTitle: false,
        backgroundColor: colorScheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        actions: [
          if (_logFilesByDate.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareAllLogs,
              tooltip: 'Share all logs',
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              color: colorScheme.error,
              onPressed: _deleteAllLogs,
              tooltip: 'Delete all logs',
            ),
          ],
        ],
      ),
      body: _buildBody(colorScheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logFilesByDate.isEmpty) {
      return _EmptyState(onRefresh: _loadLogFiles);
    }

    return RefreshIndicator(
      onRefresh: _loadLogFiles,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _logFilesByDate.length,
        itemBuilder: (context, index) {
          final date = _logFilesByDate.keys.elementAt(index);
          final files = _logFilesByDate[date]!;
          return _DateGroup(
            date: date,
            files: files,
            isExpanded: _expandedDate == date,
            displayDate: _formatDateForDisplay(date),
            onToggle: () => setState(
              () => _expandedDate = _expandedDate == date ? null : date,
            ),
            onDeleteDate: () => _deleteDate(date),
            onViewFile: _viewFile,
            onShareFile: _shareFile,
            onDeleteFile: _deleteFile,
          );
        },
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────

  String _formatDateForDisplay(String date) {
    try {
      final dt = DateFormat('yyyy-MM-dd').parse(date);
      final now = DateTime.now();
      if (_isSameDay(dt, now)) return 'Today';
      if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) {
        return 'Yesterday';
      }
      return DateFormat('EEEE, MMMM d, yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Date Group Card ───────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final String date;
  final List<File> files;
  final bool isExpanded;
  final String displayDate;
  final VoidCallback onToggle;
  final VoidCallback onDeleteDate;
  final void Function(File) onViewFile;
  final void Function(File) onShareFile;
  final void Function(File) onDeleteFile;

  const _DateGroup({
    required this.date,
    required this.files,
    required this.isExpanded,
    required this.displayDate,
    required this.onToggle,
    required this.onDeleteDate,
    required this.onViewFile,
    required this.onShareFile,
    required this.onDeleteFile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${files.length} file${files.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    onPressed: onDeleteDate,
                    tooltip: 'Delete all for this date',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
          // Expandable file list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                ...files.map(
                  (f) => _FileTile(
                    file: f,
                    onView: () => onViewFile(f),
                    onShare: () => onShareFile(f),
                    onDelete: () => onDeleteFile(f),
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── File Tile ─────────────────────────────────────────────────────────────

class _FileTile extends StatelessWidget {
  final File file;
  final VoidCallback onView;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _FileTile({
    required this.file,
    required this.onView,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileName = file.path.split('/').last;

    return FutureBuilder<int>(
      future: WiseLogger.getFileSize(file),
      builder: (context, snapshot) {
        final sizeBytes = snapshot.data ?? 0;
        final sizeStr = WiseLogger.formatFileSize(sizeBytes);
        final isLarge = sizeBytes >= _kChunkedThreshold;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              size: 18,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          title: Text(
            fileName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Row(
            children: [
              Text(
                sizeStr,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (isLarge) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LARGE',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.visibility_outlined,
                tooltip: 'View',
                onPressed: onView,
              ),
              _ActionIconButton(
                icon: Icons.share_outlined,
                tooltip: 'Share',
                onPressed: onShare,
              ),
              _ActionIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Delete',
                color: colorScheme.error,
                onPressed: onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: onPressed,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }
}

// ─── Log File Viewer ───────────────────────────────────────────────────────

/// Displays a log file with:
/// - Chunked loading (200 lines at a time) for large files
/// - Infinite scroll — loads more lines as user reaches the bottom
/// - Search bar with match highlighting and navigation
/// - Log-level color coding per line
/// - Line number gutter
class _LogFileViewer extends StatefulWidget {
  final File file;
  final VoidCallback onClose;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _LogFileViewer({
    required this.file,
    required this.onClose,
    required this.onShare,
    required this.onDelete,
  });

  @override
  State<_LogFileViewer> createState() => _LogFileViewerState();
}

class _LogFileViewerState extends State<_LogFileViewer> {
  // All lines read from file
  List<String> _allLines = [];
  // Lines currently rendered
  List<String> _visibleLines = [];
  int _loadedPageCount = 0;
  bool _hasMore = false;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _isLargeFile = false;

  // Search
  bool _searchVisible = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<int> _matchIndices = []; // indices into _visibleLines
  int _currentMatchIndex = 0;
  final _searchFocus = FocusNode();

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFile();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ─── File Loading ────────────────────────────────────────────────────

  Future<void> _loadFile() async {
    try {
      final size = await WiseLogger.getFileSize(widget.file);
      _isLargeFile = size >= _kChunkedThreshold;

      // Read lines in a background isolate so the UI thread is never
      // blocked — critical for files above ~1 MB.
      final path = widget.file.path;
      _allLines = await compute(_readLinesSync, path);

      _loadedPageCount = 0;
      _visibleLines = [];
      _isLoadingMore = false;

      // Load first page before setState marks loading as done,
      // so the list is populated on the very first frame.
      _appendNextPage();
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          // ignore: use_build_context_synchronously
          context,
          'Failed to read log file',
          type: SnackBarMessageType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  /// Appends the next [_kLinesPerPage] lines to [_visibleLines].
  ///
  /// [_isLoadingMore] is set synchronously *before* setState so the scroll
  /// listener cannot enqueue a second call in the gap between the guard
  /// check and the setState flush — the root cause of the original bug.
  void _appendNextPage() {
    if (_isLoadingMore) return;

    final start = _loadedPageCount * _kLinesPerPage;
    if (start >= _allLines.length) {
      if (mounted) setState(() => _hasMore = false);
      return;
    }

    // Mark busy synchronously — before any async gap or setState.
    _isLoadingMore = true;

    final end = (start + _kLinesPerPage).clamp(0, _allLines.length);
    final newLines = _allLines.sublist(start, end);

    if (mounted) {
      setState(() {
        _visibleLines.addAll(newLines);
        _loadedPageCount++;
        _hasMore = end < _allLines.length;
        _isLoadingMore = false; // clear atomically inside setState
      });
    } else {
      _isLoadingMore = false;
    }

    if (_searchQuery.isNotEmpty) _computeMatches();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    // Trigger 600 px before the bottom so the next page is ready
    // before the user actually hits the end.
    if (pos.pixels < pos.maxScrollExtent - 600) return;
    if (!_hasMore || _isLoadingMore) return;

    // Defer to next frame — scroll notifications fire during layout and
    // calling setState here triggers "setState called during build".
    // The post-frame guard re-checks flags so rapid scroll events don't
    // stack up multiple loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hasMore && !_isLoadingMore) {
        _appendNextPage();
      }
    });
  }

  // ─── Search ──────────────────────────────────────────────────────────

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query == _searchQuery) return;
    setState(() {
      _searchQuery = query;
      _currentMatchIndex = 0;
    });
    _computeMatches();
  }

  void _computeMatches() {
    if (_searchQuery.isEmpty) {
      setState(() => _matchIndices = []);
      return;
    }
    final matches = <int>[];
    for (int i = 0; i < _visibleLines.length; i++) {
      if (_visibleLines[i].toLowerCase().contains(_searchQuery)) {
        matches.add(i);
      }
    }
    setState(() => _matchIndices = matches);
  }

  void _jumpToMatch(int delta) {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatchIndex = (_currentMatchIndex + delta) % _matchIndices.length;
    });
    // Approximate scroll: each line ~18px
    final lineIndex = _matchIndices[_currentMatchIndex];
    _scrollController.animateTo(
      lineIndex * 18.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchController.clear();
        _searchQuery = '';
        _matchIndices = [];
      } else {
        _searchFocus.requestFocus();
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileName = widget.file.path.split('/').last;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // dark terminal background
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: widget.onClose,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '${_allLines.length} lines · ${_visibleLines.length} loaded'
              '${_isLargeFile ? ' · chunked' : ''}',
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: _searchVisible ? colorScheme.primary : Colors.white70,
            ),
            onPressed: _toggleSearch,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white70),
            onPressed: widget.onShare,
            tooltip: 'Share',
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.error.withValues(alpha: 0.8),
            ),
            onPressed: widget.onDelete,
            tooltip: 'Delete',
          ),
        ],
        bottom: _searchVisible ? _buildSearchBar(colorScheme) : null,
      ),
      body: _isInitialLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white30),
            )
          : _allLines.isEmpty
          ? _buildEmptyFile()
          : _buildLineList(colorScheme),
    );
  }

  PreferredSizeWidget _buildSearchBar(ColorScheme colorScheme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(52),
      child: Container(
        color: const Color(0xFF161B22),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search in file…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white38,
                    size: 18,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? Text(
                          _matchIndices.isEmpty
                              ? 'No matches'
                              : '${_currentMatchIndex + 1}/${_matchIndices.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ).withPadding(
                          const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white54,
              ),
              onPressed: () => _jumpToMatch(-1),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white54,
              ),
              onPressed: () => _jumpToMatch(1),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineList(ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _visibleLines.length + (_hasMore ? 1 : 0),
      // addAutomaticKeepAlives=false and addRepaintBoundaries=false are
      // important for large lists — avoids unnecessary widget lifecycle work.
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index == _visibleLines.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white24,
                ),
              ),
            ),
          );
        }

        final line = _visibleLines[index];
        final lineNumber = index + 1;
        final isMatchLine = _matchIndices.contains(index);
        final isCurrentMatch =
            _matchIndices.isNotEmpty &&
            _matchIndices[_currentMatchIndex] == index;

        return _LogLine(
          lineNumber: lineNumber,
          content: line,
          searchQuery: _searchQuery,
          isMatch: isMatchLine,
          isCurrentMatch: isCurrentMatch,
        );
      },
    );
  }

  Widget _buildEmptyFile() {
    return const Center(
      child: Text('File is empty', style: TextStyle(color: Colors.white38)),
    );
  }
}

// ─── Log Line Widget ───────────────────────────────────────────────────────

/// A single line in the log viewer. Kept as a const-friendly StatelessWidget
/// so the list builder can skip rebuilding unchanged lines.
class _LogLine extends StatelessWidget {
  final int lineNumber;
  final String content;
  final String searchQuery;
  final bool isMatch;
  final bool isCurrentMatch;

  const _LogLine({
    required this.lineNumber,
    required this.content,
    required this.searchQuery,
    required this.isMatch,
    required this.isCurrentMatch,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(content);
    final bg = isCurrentMatch
        ? Colors.yellow.withValues(alpha: 0.15)
        : isMatch
        ? Colors.yellow.withValues(alpha: 0.06)
        : Colors.transparent;

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line number gutter
          SizedBox(
            width: 48,
            child: Text(
              '$lineNumber',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white24,
                fontFamily: 'monospace',
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Level indicator bar
          Container(
            width: 2,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            color: levelColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: searchQuery.isNotEmpty && isMatch
                ? _HighlightedText(
                    text: content,
                    query: searchQuery,
                    baseColor: levelColor,
                    isCurrent: isCurrentMatch,
                  )
                : Text(
                    content,
                    style: TextStyle(
                      fontSize: 11,
                      color: levelColor,
                      fontFamily: 'monospace',
                      height: 1.6,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  /// Returns a color based on detected log level in the line content.
  static Color _levelColor(String line) {
    final upper = line.toUpperCase();
    if (upper.contains('[FATAL]') || upper.contains('F/')) {
      return const Color(0xFFFF4C4C);
    }
    if (upper.contains('[ERROR]') || upper.contains('E/')) {
      return const Color(0xFFFF7070);
    }
    if (upper.contains('[WARNING]') ||
        upper.contains('[WARN]') ||
        upper.contains('W/')) {
      return const Color(0xFFFFD060);
    }
    if (upper.contains('[INFO]') || upper.contains('I/')) {
      return const Color(0xFF6DC8FF);
    }
    if (upper.contains('[DEBUG]') || upper.contains('D/')) {
      return const Color(0xFF98C379);
    }
    if (upper.contains('[TRACE]') || upper.contains('T/')) {
      return const Color(0xFF888888);
    }
    return const Color(0xFFAAAAAA);
  }
}

// ─── Highlighted Text ──────────────────────────────────────────────────────

/// Renders [text] with [query] occurrences highlighted.
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final Color baseColor;
  final bool isCurrent;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.baseColor,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: baseColor,
          fontFamily: 'monospace',
          height: 1.6,
        ),
      );
    }

    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lower.indexOf(query, start);
      if (idx == -1) {
        spans.add(
          TextSpan(
            text: text.substring(start),
            style: TextStyle(color: baseColor),
          ),
        );
        break;
      }
      if (idx > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, idx),
            style: TextStyle(color: baseColor),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: TextStyle(
            color: Colors.black,
            backgroundColor: isCurrent
                ? Colors.yellow
                : Colors.yellow.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + query.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(
        fontSize: 11,
        fontFamily: 'monospace',
        height: 1.6,
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No log files found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logs will appear here once the app starts generating them.',
              style: TextStyle(fontSize: 14, color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Extension Helpers ─────────────────────────────────────────────────────

extension on Widget {
  Widget withPadding(EdgeInsets padding) =>
      Padding(padding: padding, child: this);
}
