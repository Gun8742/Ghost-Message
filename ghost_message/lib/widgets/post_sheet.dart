import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghost_message/models/post_model.dart';
import 'package:ghost_message/models/reply_model.dart';
import 'package:ghost_message/models/user_model.dart';
import 'package:ghost_message/providers/l_provider.dart';
import 'package:ghost_message/providers/theme_provider.dart';
import 'package:ghost_message/providers/user_provider.dart';
import 'package:ghost_message/services/report_firestore_service.dart';
import 'package:ghost_message/services/social_service.dart';
import 'package:provider/provider.dart';

class PostSheet extends StatefulWidget {
  final PostModel post;
  final UserModel currentUser;
  const PostSheet({
    super.key,
    required this.post,
    required this.currentUser
  });

  @override
  State<PostSheet> createState() => _PostSheetState();
}

class _PostSheetState extends State<PostSheet> {
  final SocialService _socialService = SocialService();
  final TextEditingController _replyController = TextEditingController();
  late bool _isLiked;
  late int _currentLikeCount;


  @override
  void initState() {
    super.initState();
    _isLiked = widget.currentUser.likedPosts.contains(widget.post.postId);
    _currentLikeCount = widget.post.likeCount;
  }

  void _toggleLike() async {
    setState(() {
      if (_isLiked) {
        _currentLikeCount--;
        _isLiked = false;
        widget.currentUser.likedPosts.remove(widget.post.postId);
      }
      else {
        _currentLikeCount++;
        _isLiked = true;
        widget.currentUser.likedPosts.add(widget.post.postId);
      }
    });
      try {
        await _socialService.toggleLike(
          postId: widget.post.postId,
          postOwnerId: widget.post.authorId,
          userId: widget.currentUser.uid,
          isCurrentlyLiked: !_isLiked,
        );
      }
      catch (e) {
        print(e);
      }
    }

    void _sendReply() async {
      final text = _replyController.text.trim();
      if (text.isEmpty) return;
      final newReply = ReplyModel(
        replyId: FirebaseFirestore.instance.collection('tmp').doc().id,
        postId: widget.post.postId,
        authorId: widget.currentUser.uid,
        message: text,
        createdAt: DateTime.now(),
      );
      _replyController.clear();
      try {
        await _socialService.addReply(reply: newReply);
        Provider.of<UserProvider>(context, listen: false).gainExp(3);
      } catch (e) {
        print(e);
      }
    }
    void _showReportDialog(String targetId, ReportType type) {
      final TextEditingController reasonController = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) {
          final l = Provider.of<L>(context, listen: false);
          String title = l.reportReasonTitle;
          if (type == ReportType.user) {
            title = l.reportUserWithReason;
          } 
          else if (type == ReportType.message) {
            title = l.reportPostWithReason;
          }
          else if (type == ReportType.reply) {
            title = l.reportReplyWithReason;
          }
          final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
          return AlertDialog(
            backgroundColor: themeProvider.currentBgColor,
            title: Text(title),
            content: TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l.reportReasonHint,
                hintStyle: TextStyle(color: themeProvider.currentHintColor),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            actions: [
              TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel, style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () async {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) return;

                  Navigator.pop(context);
                  try {
                    await ReportFirestoreService().submitToReport(
                      type: type,
                      targetId: targetId,
                      reportedByUid: widget.currentUser.uid,
                      reason: reason,
                      parentId: widget.post.postId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.reportSuccess)),
                      );
                    }
                  }
                  catch (e) {
                    print("Report Error: $e");
                  }
                },
                child: Text(l.submitReport, style: TextStyle(color: Colors.white)),
              )
            ],
          );
        }
      );
    }

    void _deletePost() async {
      try {
        await _socialService.deletePost(widget.post.postId, widget.currentUser.uid);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ลบโพสต์เรียบร้อยแล้ว")),
          );
        }
      } catch (e) {
        print("Delete Post Error: $e");
      }
    }

    void _deleteReply(String replyId) async {
      try {
        await _socialService.deleteReply(widget.post.postId, replyId, widget.currentUser.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ลบความคิดเห็นเรียบร้อยแล้ว")),
          );
        }
      } catch (e) {
        print("Delete Reply Error: $e");
      }
    }

    @override
    void dispose() {
      _replyController.dispose();
      super.dispose();
    }
    @override
    Widget build(BuildContext context) {
      final l = Provider.of<L>(context);
      final themeProvider = Provider.of<ThemeProvider>(context);
      final userProvider = Provider.of<UserProvider>(context);
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.currentBgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.postTitle, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: themeProvider.currentHintColor
                  )
                ),
                
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: themeProvider.currentHintColor),
                  onSelected: (value) {
                    if (value == 'report_post') {
                      _showReportDialog(widget.post.postId, ReportType.message);
                    } 
                    else if (value == 'report_user') {
                      _showReportDialog(widget.post.authorId, ReportType.user);
                    }
                    else if (value == 'delete_post') {
                      _deletePost();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final l = Provider.of<L>(context, listen: false);

                    final bool isOwner = widget.post.authorId == widget.currentUser.uid;
                    return [
                      if (!isOwner) ...[
                        PopupMenuItem(
                          value: 'report_post',
                          child: Row(
                            children: [
                              const Icon(Icons.flag_outlined, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Text(l.reportPost),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'report_user',
                          child: Row(
                            children: [
                              const Icon(Icons.person_off_outlined, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(l.reportUser),
                            ],
                          ),
                        ),
                      ]
                      else ...[
                        PopupMenuItem(
                          value: 'delete_post',
                          child: Row(children: [const Icon(Icons.delete_outline, color: Colors.red), const SizedBox(width: 8), Text(l.adminDelete)]),
                        ),
                      ],
                    ];
                  },
                )
              ],
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: themeProvider.currentHintColor.withOpacity(0.2),
                backgroundImage: (userProvider.getPhotoPath(widget.post.authorId) != null && 
                                  userProvider.getPhotoPath(widget.post.authorId)!.isNotEmpty)
                    ? NetworkImage(userProvider.getPhotoPath(widget.post.authorId)!)
                    : null,
                child: (userProvider.getPhotoPath(widget.post.authorId) == null || 
                        userProvider.getPhotoPath(widget.post.authorId)!.isEmpty)
                    ? Icon(Icons.person, color: themeProvider.currentHintColor)
                    : null,
              ),
              title: Text(
                "@${userProvider.getUsernameById(widget.post.authorId)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: themeProvider.currentTextColor,
                  fontSize: 14,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  widget.post.message,
                  style: TextStyle(fontSize: 16, color: themeProvider.currentTextColor),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: _isLiked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$_currentLikeCount'),
                const SizedBox(width: 20),
                Icon(Icons.chat_bubble_outline, color: themeProvider.currentHintColor, size: 20),
                const SizedBox(width: 8),
                Text('${widget.post.replyCount}'),
              ],
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<ReplyModel>>(
                stream: _socialService.getRepliedStream(widget.post.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text(
                      l.noReplyYet,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: themeProvider.currentTextColor
                        ),
                    ));
                  }
                  final replies = snapshot.data!;
                  return ListView.builder(
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      final reply = replies[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: themeProvider.currentHintColor.withOpacity(0.2),
                          backgroundImage: (userProvider.getPhotoPath(reply.authorId) != null && 
                                            userProvider.getPhotoPath(reply.authorId)!.isNotEmpty)
                              ? NetworkImage(userProvider.getPhotoPath(reply.authorId)!)
                              : null,
                          child: (userProvider.getPhotoPath(reply.authorId) == null || 
                                  userProvider.getPhotoPath(reply.authorId)!.isEmpty)
                              ? Icon(Icons.person, color: themeProvider.currentHintColor)
                              : null,
                        ),
                        title: Text(
                          "@${userProvider.getUsernameById(reply.authorId)}", 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: themeProvider.currentTextColor)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(reply.message, style: TextStyle(fontSize: 15, color: themeProvider.currentTextColor)),
                            const SizedBox(height: 4),
                            Text(reply.createdAt.toString().substring(0, 16), style: TextStyle(fontSize: 12, color: themeProvider.currentHintColor)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Builder(
                              builder: (context) {
                                final isReplyLiked = widget.currentUser.likedReplies.contains(reply.replyId);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isReplyLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        size: 16,
                                        color: isReplyLiked ? Colors.blue: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          if (isReplyLiked) {
                                            widget.currentUser.likedReplies.remove(reply.replyId);
                                          } else {
                                            widget.currentUser.likedReplies.add(reply.replyId);
                                          }
                                        });
                                        try {
                                          await _socialService.toggleLikeReply(
                                            postId: widget.post.postId,
                                            replyId: reply.replyId,
                                            userId: widget.currentUser.uid,
                                            isCurrentlyLiked: isReplyLiked,
                                          );
                                        } catch (e) {
                                          print(e);
                                        }
                                      }
                                    ),
                                    Text('${reply.likeCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ]
                                );
                              },
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_vert, size: 18, color: themeProvider.currentHintColor),
                              onSelected: (value) {
                                if (value == 'report_reply') {
                                  _showReportDialog(reply.replyId, ReportType.reply);
                                } 
                                else if (value == 'report_user') {
                                  _showReportDialog(reply.authorId, ReportType.user);
                                }
                                else if (value == 'delete_reply') {
                                  _deleteReply(reply.replyId);
                                }
                              },
                              itemBuilder: (context) {
                                final l = Provider.of<L>(context, listen: false); 
                                final bool isReplyOwner = reply.authorId == widget.currentUser.uid;
                                return [
                                  if (!isReplyOwner) ...[
                                    PopupMenuItem(
                                      value: 'report_reply',
                                      height: 30,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.flag_outlined, size: 16, color: Colors.orange),
                                          const SizedBox(width: 8),
                                          Text(l.reportReply, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'report_user',
                                      height: 30,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_off_outlined, size: 16, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(l.reportUser, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ]
                                  else ...[
                                    PopupMenuItem(
                                      value: 'delete_reply',
                                      height: 30,
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(l.adminDelete, style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ]
                                ];
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              child:
                Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          hintText: l.replyHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendReply,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }