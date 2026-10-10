import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({Key? key}) : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _questions = [];
  bool _loading = true;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  int? _expandedQuestionId;
  Timer? _debounce;
  Map<int, Map<String, dynamic>> _questionDetails = {};
  Map<int, bool> _loadingDetails = {};
  Map<int, String> _voteStatus = {}; // questionId -> 'like' or 'dislike'

  @override
  void initState() {
    super.initState();
    _loadVoteStatus();
    _fetchQuestions();
  }

  Future<void> _loadVoteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Object> all = prefs.getKeys().fold({}, (map, key) {
      if (key.startsWith('faq_vote_')) {
        map[key] = prefs.getString(key) ?? '';
      }
      return map;
    });
    setState(() {
      _voteStatus = all.map((k, v) => MapEntry(int.parse(k.replaceFirst('faq_vote_', '')), v as String));
    });
  }

  Future<void> _saveVoteStatus(int questionId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('faq_vote_$questionId', status);
    setState(() {
      _voteStatus[questionId] = status;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    setState(() => _loading = true);
    try {
      final questions = _search.isEmpty
          ? await _apiService.fetchFaqQuestions()
          : await _apiService.searchFaqQuestions(_search);
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions: $e')),
      );
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _search = value);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchQuestions();
    });
  }

  Future<void> _submitQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    try {
      await _apiService.postFaqQuestion(text);
      _questionController.clear();
      _fetchQuestions();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question submitted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit question: $e')),
      );
    }
  }

  Future<void> _submitAnswer(int questionId) async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;
    try {
      await _apiService.postFaqAnswer(questionId, text);
      _answerController.clear();
      await _fetchQuestionDetail(questionId, force: true);
      setState(() {}); // Force UI update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer submitted!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit answer: $e')),
      );
    }
  }

  Future<void> _fetchQuestionDetail(int questionId, {bool force = false}) async {
    if (!force && _questionDetails.containsKey(questionId)) return;
    setState(() => _loadingDetails[questionId] = true);
    try {
      final detail = await _apiService.fetchFaqQuestionDetail(questionId);
      setState(() {
        _questionDetails[questionId] = detail;
        _loadingDetails[questionId] = false;
      });
    } catch (e) {
      setState(() => _loadingDetails[questionId] = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load answers: $e')),
      );
    }
  }

  Future<void> _likeQuestion(int questionId) async {
    if (_voteStatus[questionId] == 'like') return; // already liked
    try {
      final likes = await _apiService.likeFaqQuestion(questionId);
      await _saveVoteStatus(questionId, 'like');
      setState(() {
        final idx = _questions.indexWhere((q) => q['id'] == questionId);
        if (idx != -1) _questions[idx]['likes'] = likes;
        if (_questionDetails.containsKey(questionId)) {
          _questionDetails[questionId]!['likes'] = likes;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like question: $e')),
      );
    }
  }

  Future<void> _dislikeQuestion(int questionId) async {
    if (_voteStatus[questionId] == 'dislike') return; // already disliked
    try {
      final dislikes = await _apiService.dislikeFaqQuestion(questionId);
      await _saveVoteStatus(questionId, 'dislike');
      setState(() {
        final idx = _questions.indexWhere((q) => q['id'] == questionId);
        if (idx != -1) _questions[idx]['dislikes'] = dislikes;
        if (_questionDetails.containsKey(questionId)) {
          _questionDetails[questionId]!['dislikes'] = dislikes;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to dislike question: $e')),
      );
    }
  }

  void _onQuestionTap(int questionId) async {
    setState(() {
      _expandedQuestionId = _expandedQuestionId == questionId ? null : questionId;
    });
    if (_expandedQuestionId == questionId) {
      await _fetchQuestionDetail(questionId);
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final isExpanded = _expandedQuestionId == q['id'];
    final likes = q['likes'] ?? 0;
    final dislikes = q['dislikes'] ?? 0;
    final detail = _questionDetails[q['id']];
    final loadingDetail = _loadingDetails[q['id']] ?? false;
    final vote = _voteStatus[q['id']];
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            onTap: () => _onQuestionTap(q['id']),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.question_answer, color: Colors.blue.shade700),
            ),
            title: Text(q['text'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up, size: 20, color: vote == 'like' ? Colors.green : Colors.grey),
                  onPressed: () => _likeQuestion(q['id']),
                  tooltip: 'Like',
                ),
                Text('$likes'),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.thumb_down, size: 20, color: vote == 'dislike' ? Colors.red : Colors.grey),
                  onPressed: () => _dislikeQuestion(q['id']),
                  tooltip: 'Dislike',
                ),
                Text('$dislikes'),
              ],
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          ),
          if (isExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: loadingDetail
                  ? const Center(child: CircularProgressIndicator())
                  : detail == null
                      ? const Text('No answers yet.')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((detail['answers'] as List).isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('No answers yet.'),
                              )
                            else ...[
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text('Answers:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              ...List.generate(
                                (detail['answers'] as List).length,
                                (i) {
                                  final a = detail['answers'][i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.blueGrey),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(a['text'] ?? '')),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextField(
                                controller: _answerController,
                                decoration: const InputDecoration(
                                  labelText: 'Write your answer',
                                  border: OutlineInputBorder(),
                                ),
                                minLines: 1,
                                maxLines: 3,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.send),
                                label: const Text('Submit Answer'),
                                onPressed: () => _submitAnswer(q['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search questions',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _questions.isEmpty
                        ? const Center(child: Text('No questions found.'))
                        : ListView.builder(
                            itemCount: _questions.length,
                            itemBuilder: (context, index) {
                              final q = _questions[index];
                              return _buildQuestionCard(q);
                            },
                          ),
              ),
              const Divider(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ask a new question', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Type your question',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Submit Question'),
                        onPressed: _submitQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 