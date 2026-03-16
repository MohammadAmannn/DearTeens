import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_colors.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────
class CommunityPost {
  final String id;
  final String text;
  final int likes;
  final int replyCount;
  final DateTime createdAt;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.text,
    required this.likes,
    required this.replyCount,
    required this.createdAt,
    required this.isLiked,
  });

  factory CommunityPost.fromFirestore(
      DocumentSnapshot doc, Set<String> likedIds) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      text: data['text'] ?? '',
      likes: data['likes'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isLiked: likedIds.contains(doc.id),
    );
  }
}

class CommunityReply {
  final String id;
  final String text;
  final DateTime createdAt;

  CommunityReply({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  factory CommunityReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommunityReply(
      id: doc.id,
      text: data['text'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final communityPostsProvider = StreamProvider<List<CommunityPost>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  return FirebaseFirestore.instance
      .collection('community_posts')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .asyncMap((snap) async {
    final likedSnap = await FirebaseFirestore.instance
        .collection('community_posts')
        .doc('liked_by_$uid')
        .get();
    final likedIds = <String>{};
    if (likedSnap.exists) {
      final data = likedSnap.data() as Map<String, dynamic>;
      likedIds.addAll((data['postIds'] as List?)?.cast<String>() ?? []);
    }
    return snap.docs
        .map((d) => CommunityPost.fromFirestore(d, likedIds))
        .toList();
  });
});

// ─── Screen ───────────────────────────────────────────────────────────────────
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _isPosting = false;
  bool _showCompose = false;

  final List<String> _exampleQuestions = [
    '💬 Is it normal to feel emotional before my period?',
    '🌸 What\'s the best way to manage period cramps?',
    '😰 How do I deal with anxiety at school?',
    '🧴 What skincare is good for teenage acne?',
    '💭 Is it normal to have irregular periods?',
  ];

  // ── AI Moderation ───────────────────────────────────────────────────────────
  Future<bool> _moderateText(String text) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey != null &&
          apiKey.isNotEmpty &&
          apiKey != 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
        final model =
            GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
        final prompt =
            'Is this message appropriate for a teen health app? '
            'Reply with only "YES" or "NO": "$text"';
        final response =
            await model.generateContent([Content.text(prompt)]);
        return response.text?.toUpperCase().contains('YES') ?? true;
      }
    } catch (_) {}
    return true; // allow if moderation fails
  }

  // ── Submit Post ─────────────────────────────────────────────────────────────
  Future<void> _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPosting = true);

    try {
      final isAppropriate = await _moderateText(text);

      if (!isAppropriate) {
        setState(() => _isPosting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please keep questions related to teen health topics 💕',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance.collection('community_posts').add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'replyCount': 0,
        'postId': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      _postController.clear();
      setState(() {
        _isPosting = false;
        _showCompose = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Question posted anonymously! 🎉',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isPosting = false);
    }
  }

  // ── Like Post ───────────────────────────────────────────────────────────────
  Future<void> _likePost(
      String postId, int currentLikes, bool isLiked) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId);
      await ref
          .update({'likes': isLiked ? currentLikes - 1 : currentLikes + 1});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF5C35F5),
                      Color(0xFF7C7CF8),
                      Color(0xFFAA9FF8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.forum_rounded,
                                      color: Colors.white,
                                      size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Safe Space 🤝',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: Colors.white)),
                                    Text(
                                        'Anonymous & AI-moderated',
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color:
                                                Colors.white70)),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration:
                                            const BoxDecoration(
                                          color: Color(0xFF69FF47),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text('Safe',
                                          style:
                                              GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  color:
                                                      Colors.white,
                                                  fontWeight:
                                                      FontWeight
                                                          .w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Safety Note ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_rounded,
                      color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'All posts & replies are anonymous & AI-moderated for your safety.',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Compose Section ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: AnimatedCrossFade(
                firstChild: _buildComposeButton(),
                secondChild: _buildComposeForm(),
                crossFadeState: _showCompose
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),

          // ── Example Questions ──────────────────────────────────────
          if (!_showCompose)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Text(
                      'Example Questions',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMain,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 0),
                      itemCount: _exampleQuestions.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _showCompose = true);
                            _postController.text =
                                _exampleQuestions[index]
                                    .replaceAll(
                                        RegExp(r'[💬🌸😰🧴💭] '),
                                        '');
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary
                                  .withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.secondary
                                      .withOpacity(0.2)),
                            ),
                            child: Text(
                              _exampleQuestions[index],
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

          // ── Posts Header ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_rounded,
                      color: AppColors.secondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Community Questions',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain),
                  ),
                ],
              ).animate().fadeIn(),
            ),
          ),

          // ── Posts List ──────────────────────────────────────────────
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverToBoxAdapter(
                    child: _buildEmptyState());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PostCard(
                    post: posts[index],
                    onLike: _likePost,
                    delay: (index * 60).ms,
                  ),
                  childCount: posts.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                    color: AppColors.secondary),
              )),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.signal_wifi_off_rounded,
                          color: AppColors.textLight, size: 48),
                      const SizedBox(height: 12),
                      Text('Could not load posts',
                          style: GoogleFonts.poppins(
                              color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(
              padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildComposeButton() {
    return GestureDetector(
      onTap: () => setState(() => _showCompose = true),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.secondary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Ask anything anonymously... 💭',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textHint),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: AppColors.secondaryGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Ask',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.secondary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤫 Your identity is completely hidden',
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _postController,
            maxLines: 4,
            style: GoogleFonts.poppins(
                color: AppColors.textMain, fontSize: 14),
            decoration: InputDecoration(
              hintText:
                  'What\'s on your mind? Ask your health question...',
              hintStyle: GoogleFonts.poppins(
                  color: AppColors.textHint, fontSize: 13),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _showCompose = false;
                    _postController.clear();
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(
                        color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded,
                                size: 16),
                            const SizedBox(width: 6),
                            Text('Post Anonymously',
                                style: GoogleFonts.poppins(
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Text('💬', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Be the first to ask!',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain),
          ),
          const SizedBox(height: 8),
          Text(
            'This is a safe space for teenagers to ask health questions anonymously.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textLight,
                height: 1.4),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}

// ─── Post Card (with Replies) ─────────────────────────────────────────────────
class _PostCard extends StatefulWidget {
  final CommunityPost post;
  final Function(String, int, bool) onLike;
  final Duration delay;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.delay,
  });

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool _isLiked;
  late int _likeCount;
  bool _showReplies = false;
  bool _showReplyCompose = false;
  bool _isPostingReply = false;
  final TextEditingController _replyController = TextEditingController();
  List<CommunityReply> _replies = [];
  bool _loadingReplies = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likes;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // ── Load replies from Firestore subcollection ──
  Future<void> _loadReplies() async {
    setState(() => _loadingReplies = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .collection('replies')
          .orderBy('createdAt', descending: false)
          .limit(30)
          .get();

      setState(() {
        _replies =
            snap.docs.map((d) => CommunityReply.fromFirestore(d)).toList();
        _loadingReplies = false;
      });
    } catch (e) {
      setState(() => _loadingReplies = false);
    }
  }

  // ── Submit reply with AI moderation ──
  Future<void> _submitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isPostingReply = true);

    try {
      // AI moderation
      bool isAppropriate = true;
      try {
        final apiKey = dotenv.env['GEMINI_API_KEY'];
        if (apiKey != null &&
            apiKey.isNotEmpty &&
            apiKey != 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
          final model =
              GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
          final prompt =
              'Is this reply appropriate for a teen health app? '
              'Reply with only "YES" or "NO": "$text"';
          final response =
              await model.generateContent([Content.text(prompt)]);
          isAppropriate =
              response.text?.toUpperCase().contains('YES') ?? true;
        }
      } catch (_) {}

      if (!isAppropriate) {
        setState(() => _isPostingReply = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please keep replies supportive and related to health 💕',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return;
      }

      // Add reply to subcollection
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .collection('replies')
          .add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment reply count on parent post
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .update({'replyCount': FieldValue.increment(1)});

      _replyController.clear();
      setState(() {
        _isPostingReply = false;
        _showReplyCompose = false;
      });

      // Reload replies
      await _loadReplies();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Reply posted anonymously! 💬',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isPostingReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.secondary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Post Content ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Anonymous header
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF7C7CF8),
                              Color(0xFFAA9FF8)
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Anonymous Teen',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppColors.textSecondary)),
                          Text(
                              _timeAgo(
                                  widget.post.createdAt),
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color:
                                      AppColors.textLight)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                                Icons.verified_rounded,
                                color: AppColors.success,
                                size: 12),
                            const SizedBox(width: 3),
                            Text('Safe',
                                style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppColors.success,
                                    fontWeight:
                                        FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Post text
                  Text(
                    widget.post.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textMain,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Action Buttons ──────────────────────────────
                  Row(
                    children: [
                      // Like button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                            _likeCount +=
                                _isLiked ? 1 : -1;
                          });
                          widget.onLike(
                              widget.post.id,
                              widget.post.likes,
                              !_isLiked);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7),
                          decoration: BoxDecoration(
                            color: _isLiked
                                ? AppColors.primary
                                    .withOpacity(0.1)
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: _isLiked
                                  ? AppColors.primary
                                      .withOpacity(0.3)
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                _isLiked
                                    ? Icons
                                        .favorite_rounded
                                    : Icons
                                        .favorite_outline_rounded,
                                color: _isLiked
                                    ? AppColors.primary
                                    : AppColors.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '$_likeCount',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: _isLiked
                                      ? AppColors.primary
                                      : AppColors
                                          .textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reply toggle button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showReplies =
                                !_showReplies;
                            if (_showReplies &&
                                _replies.isEmpty) {
                              _loadReplies();
                            }
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7),
                          decoration: BoxDecoration(
                            color: _showReplies
                                ? AppColors.secondary
                                    .withOpacity(0.1)
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: _showReplies
                                  ? AppColors.secondary
                                      .withOpacity(0.3)
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              Icon(
                                _showReplies
                                    ? Icons
                                        .chat_bubble_rounded
                                    : Icons
                                        .chat_bubble_outline_rounded,
                                color: _showReplies
                                    ? AppColors
                                        .secondary
                                    : AppColors
                                        .textLight,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.post.replyCount}',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: _showReplies
                                      ? AppColors
                                          .secondary
                                      : AppColors
                                          .textLight,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Replies',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: _showReplies
                                      ? AppColors
                                          .secondary
                                      : AppColors
                                          .textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Write reply button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showReplies = true;
                            _showReplyCompose = true;
                            if (_replies.isEmpty) {
                              _loadReplies();
                            }
                          });
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7),
                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: AppColors
                                  .secondaryGradient,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              const Icon(
                                  Icons
                                      .reply_rounded,
                                  color: Colors.white,
                                  size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Reply',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Replies Section (expandable) ──────────────────────────
            if (_showReplies) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.7),
                  border: Border(
                    top: BorderSide(
                        color: AppColors.cardBorder, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Replies list
                    if (_loadingReplies)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary),
                          ),
                        ),
                      )
                    else if (_replies.isEmpty &&
                        !_showReplyCompose)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                  Icons
                                      .chat_bubble_outline_rounded,
                                  color: AppColors.textHint,
                                  size: 28),
                              const SizedBox(height: 8),
                              Text(
                                'No replies yet. Be the first to reply!',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._replies.asMap().entries.map(
                            (entry) => _ReplyBubble(
                              reply: entry.value,
                              index: entry.key,
                            ),
                          ),

                    // ── Reply compose form ──────────────────────────
                    if (_showReplyCompose)
                      _buildReplyCompose()
                    else if (!_loadingReplies)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 12),
                        child: GestureDetector(
                          onTap: () => setState(
                              () => _showReplyCompose = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(24),
                              border: Border.all(
                                  color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary
                                        .withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                      Icons.person_rounded,
                                      color:
                                          AppColors.secondary,
                                      size: 14),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Write a supportive reply...',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          AppColors.textHint),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ).animate()
          .fadeIn(duration: 350.ms, delay: widget.delay),
    );
  }

  Widget _buildReplyCompose() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.secondary.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: AppColors.secondaryGradient),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  'Replying anonymously',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(
                      () => _showReplyCompose = false),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textHint, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _replyController,
              maxLines: 3,
              minLines: 1,
              autofocus: true,
              style: GoogleFonts.poppins(
                  color: AppColors.textMain, fontSize: 13),
              decoration: InputDecoration(
                hintText:
                    'Share your support or advice... 💕',
                hintStyle: GoogleFonts.poppins(
                    color: AppColors.textHint, fontSize: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: AppColors.success,
                          size: 12),
                      const SizedBox(width: 4),
                      Text('AI moderated',
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: _isPostingReply
                        ? null
                        : _submitReply,
                    icon: _isPostingReply
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child:
                                CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5))
                        : const Icon(Icons.send_rounded,
                            size: 14),
                    label: Text(
                      _isPostingReply
                          ? 'Posting...'
                          : 'Reply',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1),
    );
  }
}

// ─── Reply Bubble ─────────────────────────────────────────────────────────────
class _ReplyBubble extends StatelessWidget {
  final CommunityReply reply;
  final int index;

  const _ReplyBubble({required this.reply, required this.index});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Generate a consistent but random-looking avatar color from index
  Color _avatarColor() {
    final colors = [
      const Color(0xFFFF6B9A),
      const Color(0xFF7C7CF8),
      const Color(0xFF4ECDC4),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
    ];
    return colors[reply.id.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          // Reply content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                    color: AppColors.cardBorder.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Anonymous Helper',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textHint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeAgo(reply.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.text,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textMain,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideX(begin: 0.05);
  }
}
