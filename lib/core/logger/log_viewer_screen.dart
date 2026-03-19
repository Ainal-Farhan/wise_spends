import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

// ─── Constants ─────────────────────────────────────────────────────────────

const int _kLinesPerPage = 200;
const int _kChunkedThreshold = 512 * 1024; // 512 KB

/// Matches lines that begin a new log entry, e.g.:
///   [2026-03-19 09:49:35.643] [DEBUG] ...
final _kTimestampPrefix = RegExp(r'^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}');

List<String> _readLinesSync(String path) => File(path).readAsLinesSync();

// ─── Log Entry (logical unit) ──────────────────────────────────────────────

/// A [LogEntry] represents one logical log event.
/// It may span multiple raw lines (e.g. a stack trace attached to a [FATAL]).
class LogEntry {
  /// All raw lines that belong to this entry, in order.
  final List<String> lines;

  const LogEntry(this.lines);

  /// The first (header) line — contains the timestamp + level + message.
  String get header => lines.first;

  /// The full text of this entry, joining all lines with newlines.
  String get fullText => lines.join('\n');

  /// Whether this entry has continuation lines (stack trace / extra context).
  bool get isMultiLine => lines.length > 1;
}

/// Groups a flat list of raw [lines] into [LogEntry] objects.
///
/// A new entry starts whenever a line matches [_kTimestampPrefix].
/// Lines that do not match (continuation lines) are appended to the
/// most-recently-started entry.
List<LogEntry> _groupIntoEntries(List<String> lines) {
  final entries = <LogEntry>[];
  List<String>? current;

  for (final line in lines) {
    if (_kTimestampPrefix.hasMatch(line)) {
      // Start a brand-new logical entry.
      current = [line];
      entries.add(LogEntry(current));
    } else {
      if (current != null) {
        // Continuation line — belongs to the current entry.
        current.add(line);
      } else {
        // Lines before any timestamp (file header, blank lines, etc.)
        // each get their own single-line entry.
        final solo = [line];
        entries.add(LogEntry(solo));
        current = solo;
      }
    }
  }

  return entries;
}

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
  File? _viewingFile;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

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

  void _viewFile(File file) => setState(() => _viewingFile = file);
  void _closeViewer() => setState(() => _viewingFile = null);

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_logFilesByDate.isEmpty) return _EmptyState(onRefresh: _loadLogFiles);

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

class _LogFileViewerState extends State<_LogFileViewer>
    with SingleTickerProviderStateMixin {
  /// All raw lines from the file (used for stats display only).
  List<String> _allRawLines = [];

  /// All logical entries parsed from the file.
  List<LogEntry> _allEntries = [];

  /// Logical entries currently shown (paginated).
  List<LogEntry> _visibleEntries = [];

  int _loadedPageCount = 0;
  bool _hasMore = false;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _isLargeFile = false;

  // Search — operates on entry headers for simplicity
  bool _searchVisible = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// Indices (into [_visibleEntries]) that match the current search query.
  List<int> _matchIndices = [];
  int _currentMatchIndex = 0;
  final _searchFocus = FocusNode();

  // Multi-select
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;
  late final Animation<double> _bottomBarFade;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFile();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);

    _bottomBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _bottomBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _bottomBarController,
            curve: Curves.easeOutCubic,
          ),
        );
    _bottomBarFade = CurvedAnimation(
      parent: _bottomBarController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _bottomBarController.dispose();
    super.dispose();
  }

  // ─── File Loading ────────────────────────────────────────────────────

  Future<void> _loadFile() async {
    try {
      final size = await WiseLogger.getFileSize(widget.file);
      _isLargeFile = size >= _kChunkedThreshold;
      final path = widget.file.path;

      // Read raw lines in a background isolate.
      _allRawLines = await compute(_readLinesSync, path);

      // Group raw lines into logical entries on the main isolate.
      // For very large files this is still fast (~1 ms per 10k lines).
      _allEntries = _groupIntoEntries(_allRawLines);

      _loadedPageCount = 0;
      _visibleEntries = [];
      _isLoadingMore = false;
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

  void _appendNextPage() {
    if (_isLoadingMore) return;
    final start = _loadedPageCount * _kLinesPerPage;
    if (start >= _allEntries.length) {
      if (mounted) setState(() => _hasMore = false);
      return;
    }
    _isLoadingMore = true;
    final end = (start + _kLinesPerPage).clamp(0, _allEntries.length);
    final newEntries = _allEntries.sublist(start, end);
    if (mounted) {
      setState(() {
        _visibleEntries.addAll(newEntries);
        _loadedPageCount++;
        _hasMore = end < _allEntries.length;
        _isLoadingMore = false;
      });
    } else {
      _isLoadingMore = false;
    }
    if (_searchQuery.isNotEmpty) _computeMatches();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 600) return;
    if (!_hasMore || _isLoadingMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _hasMore && !_isLoadingMore) _appendNextPage();
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

  /// Search across the full text of every visible entry so stack traces
  /// and continuation lines are also matched.
  void _computeMatches() {
    if (_searchQuery.isEmpty) {
      setState(() => _matchIndices = []);
      return;
    }
    final matches = <int>[];
    for (int i = 0; i < _visibleEntries.length; i++) {
      if (_visibleEntries[i].fullText.toLowerCase().contains(_searchQuery)) {
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
    // Approximate: entries average ~2 lines × 18px each
    final entryIndex = _matchIndices[_currentMatchIndex];
    _scrollController.animateTo(
      entryIndex * 36.0,
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

  // ─── Multi-select ─────────────────────────────────────────────────────

  void _enterSelectionMode(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSelectionMode = true;
      _selectedIndices.add(index);
    });
    _bottomBarController.forward();
  }

  void _toggleEntrySelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
          _bottomBarController.reverse();
        }
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _exitSelectionMode() {
    _bottomBarController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSelectionMode = false;
          _selectedIndices.clear();
        });
      }
    });
  }

  void _selectAllEntries() {
    setState(() {
      for (int i = 0; i < _visibleEntries.length; i++) {
        _selectedIndices.add(i);
      }
    });
  }

  /// Copies the full text of all selected entries (including their
  /// continuation / stack-trace lines), separated by a blank line between
  /// multi-line entries so the output is easy to read.
  Future<void> _copySelectedEntries() async {
    if (_selectedIndices.isEmpty) return;
    final sorted = _selectedIndices.toList()..sort();
    final buffer = StringBuffer();
    for (int i = 0; i < sorted.length; i++) {
      final entry = _visibleEntries[sorted[i]];
      buffer.write(entry.fullText);
      // Separate entries with a blank line when at least one is multi-line.
      if (i < sorted.length - 1) buffer.write('\n\n');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      final count = sorted.length;
      showSnackBarMessage(
        context,
        'Copied $count entr${count == 1 ? 'y' : 'ies'} to clipboard',
        type: SnackBarMessageType.success,
      );
    }
    _exitSelectionMode();
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fileName = widget.file.path.split('/').last;
    final selectedCount = _selectedIndices.length;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectionMode) _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        appBar: AppBar(
          backgroundColor: _isSelectionMode
              ? const Color(0xFF0F2240)
              : const Color(0xFF161B22),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.3, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _isSelectionMode
                    ? _LeadingButton(
                        key: const ValueKey('cancel'),
                        icon: Icons.close_rounded,
                        label: 'Cancel',
                        onTap: _exitSelectionMode,
                      )
                    : _LeadingButton(
                        key: const ValueKey('back'),
                        icon: Icons.arrow_back_ios_new_rounded,
                        label: 'Back',
                        onTap: widget.onClose,
                      ),
              ),
            ),
          ),
          leadingWidth: 92,
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSelectionMode
                ? Align(
                    key: const ValueKey('sel_title'),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$selectedCount selected',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'Tap to toggle • includes full entry text',
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: const ValueKey('file_title'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_allEntries.length} entries · ${_allRawLines.length} lines'
                        '${_isLargeFile ? ' · chunked' : ''}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
          ),
          actions: _isSelectionMode
              ? [
                  TextButton.icon(
                    onPressed: _selectAllEntries,
                    icon: const Icon(
                      Icons.select_all_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                    label: const Text(
                      'All',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ]
              : [
                  IconButton(
                    icon: Icon(
                      Icons.search_rounded,
                      color: _searchVisible
                          ? colorScheme.primary
                          : Colors.white70,
                    ),
                    onPressed: _toggleSearch,
                    tooltip: 'Search',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.white70,
                    ),
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
          bottom: (!_isSelectionMode && _searchVisible)
              ? _buildSearchBar(colorScheme)
              : null,
        ),
        body: Stack(
          children: [
            _isInitialLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white30),
                  )
                : _allEntries.isEmpty
                ? _buildEmptyFile()
                : _buildEntryList(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _bottomBarFade,
                child: SlideTransition(
                  position: _bottomBarSlide,
                  child: _buildBottomActionBar(selectedCount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────

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

  Widget _buildEntryList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 8, bottom: _isSelectionMode ? 88 : 8),
      itemCount: _visibleEntries.length + (_hasMore ? 1 : 0),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (context, index) {
        if (index == _visibleEntries.length) {
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

        final entry = _visibleEntries[index];
        final isMatchEntry = _matchIndices.contains(index);
        final isCurrentMatch =
            _matchIndices.isNotEmpty &&
            _matchIndices[_currentMatchIndex] == index;
        final isChecked = _selectedIndices.contains(index);

        return _LogEntryTile(
          entryNumber: index + 1,
          entry: entry,
          searchQuery: _searchQuery,
          isMatch: isMatchEntry,
          isCurrentMatch: isCurrentMatch,
          isSelectionMode: _isSelectionMode,
          isChecked: isChecked,
          onTap: _isSelectionMode ? () => _toggleEntrySelection(index) : null,
          onLongPress: () => _isSelectionMode
              ? _toggleEntrySelection(index)
              : _enterSelectionMode(index),
        );
      },
    );
  }

  Widget _buildBottomActionBar(int count) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C2333),
        border: Border(top: BorderSide(color: Color(0xFF30363D), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1F6FEB).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1F6FEB).withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '$count entr${count == 1 ? 'y' : 'ies'} selected',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6DA9FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: _exitSelectionMode,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white60,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Clear', style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: count > 0 ? _copySelectedEntries : null,
            icon: const Icon(Icons.copy_rounded, size: 15),
            label: Text('Copy $count', style: const TextStyle(fontSize: 13)),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F6FEB),
              disabledBackgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFile() {
    return const Center(
      child: Text('File is empty', style: TextStyle(color: Colors.white38)),
    );
  }
}

// ─── Reusable Pill Leading Button ──────────────────────────────────────────

class _LeadingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LeadingButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: Colors.white),
              const SizedBox(width: 3),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Log Entry Tile ────────────────────────────────────────────────────────

/// Renders one [LogEntry] (which may span multiple raw lines).
///
/// - The **header line** is always shown, color-coded by log level.
/// - Continuation lines (stack trace etc.) are shown below in a dimmed
///   monospace block, visually connected to the header.
/// - A "N more lines" chip is shown when there are continuation lines,
///   making it obvious that this is a grouped multi-line entry.
class _LogEntryTile extends StatelessWidget {
  final int entryNumber;
  final LogEntry entry;
  final String searchQuery;
  final bool isMatch;
  final bool isCurrentMatch;
  final bool isSelectionMode;
  final bool isChecked;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;

  const _LogEntryTile({
    required this.entryNumber,
    required this.entry,
    required this.searchQuery,
    required this.isMatch,
    required this.isCurrentMatch,
    required this.isSelectionMode,
    required this.isChecked,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(entry.header);
    final hasExtra = entry.isMultiLine;
    final extraLines = entry.lines.skip(1).toList();

    final Color bg;
    if (isChecked) {
      bg = const Color(0xFF1F6FEB).withValues(alpha: 0.18);
    } else if (isCurrentMatch) {
      bg = Colors.yellow.withValues(alpha: 0.15);
    } else if (isMatch) {
      bg = Colors.yellow.withValues(alpha: 0.06);
    } else {
      bg = Colors.transparent;
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          border: isChecked
              ? const Border(
                  left: BorderSide(color: Color(0xFF1F6FEB), width: 3),
                )
              : null,
        ),
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox column ───────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isSelectionMode ? 38 : 0,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(),
              child: isSelectionMode
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10, top: 3),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: (_) => onTap?.call(),
                          activeColor: const Color(0xFF1F6FEB),
                          checkColor: Colors.white,
                          side: BorderSide(
                            color: isChecked
                                ? const Color(0xFF1F6FEB)
                                : Colors.white38,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Entry number ──────────────────────────────────────────
            SizedBox(
              width: 44,
              child: Text(
                '$entryNumber',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 10,
                  color: isChecked ? const Color(0xFF6DA9FF) : Colors.white24,
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── Level bar ─────────────────────────────────────────────
            // Extends full height of the entry (header + continuation).
            Column(
              children: [
                Container(
                  width: 2,
                  // Taller bar when entry has continuation lines
                  height: hasExtra ? 18 : 18,
                  margin: const EdgeInsets.only(top: 2),
                  color: levelColor.withValues(alpha: isChecked ? 1.0 : 0.7),
                ),
                if (hasExtra)
                  Container(
                    width: 2,
                    // Dotted / faded extension for continuation
                    height: (extraLines.length * 18.0).clamp(0, 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          levelColor.withValues(alpha: 0.4),
                          levelColor.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header line
                  searchQuery.isNotEmpty && isMatch
                      ? _HighlightedText(
                          text: entry.header,
                          query: searchQuery,
                          baseColor: levelColor,
                          isCurrent: isCurrentMatch,
                        )
                      : Text(
                          entry.header,
                          style: TextStyle(
                            fontSize: 11,
                            color: levelColor,
                            fontFamily: 'monospace',
                            height: 1.6,
                          ),
                        ),

                  // Continuation lines (stack trace / extra context)
                  if (hasExtra) ...[
                    const SizedBox(height: 2),
                    // Pill showing how many continuation lines
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: levelColor.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '+${extraLines.length} line${extraLines.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 9,
                              color: levelColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Continuation text block
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: levelColor.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: searchQuery.isNotEmpty && isMatch
                          ? _HighlightedText(
                              text: extraLines.join('\n'),
                              query: searchQuery,
                              baseColor: const Color(0xFF888888), // dimmed
                              isCurrent: isCurrentMatch,
                            )
                          : Text(
                              extraLines.join('\n'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF777777),
                                fontFamily: 'monospace',
                                height: 1.55,
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

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
