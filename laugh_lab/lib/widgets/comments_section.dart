import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/models/comment_model.dart';
import 'package:laugh_lab/services/comment_service.dart';
import 'package:laugh_lab/services/auth_service.dart';

class CommentsSection extends StatefulWidget {
  final String jokeId;
  
  const CommentsSection({super.key, required this.jokeId});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }
    
    final commentService = Provider.of<CommentService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to comment'),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      await commentService.createComment(
        widget.jokeId,
        _commentController.text.trim(),
      );
      
      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  Future<void> _deleteComment(String commentId) async {
    final commentService = Provider.of<CommentService>(context, listen: false);
    
    try {
      await commentService.deleteComment(commentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentService = Provider.of<CommentService>(context);
    final authService = Provider.of<AuthService>(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          const Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Add comment form
          if (authService.isLoggedIn)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Comment text field
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 3,
                    minLines: 1,
                    maxLength: AppConstants.maxCommentLength,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Submit button
                IconButton(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _addComment,
                ),
              ],
            ),
          
          // Comments list
          const SizedBox(height: 16),
          StreamBuilder<List<CommentModel>>(
            stream: commentService.getCommentsForJoke(widget.jokeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              
              final comments = snapshot.data ?? [];
              
              if (comments.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No comments yet. Be the first to comment!'),
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final isAuthor = authService.currentUserId == comment.userId;
                  
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
                        child: Text(
                          comment.authorName.isNotEmpty
                              ? comment.authorName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // Comment content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Author name and time
                            Row(
                              children: [
                                Text(
                                  comment.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeago.format(comment.createdAt),
                                  style: const TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            
                            // Comment text
                            Text(comment.content),
                          ],
                        ),
                      ),
                      
                      // Delete button (only for author)
                      if (isAuthor)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () {
                            _deleteComment(comment.id);
                          },
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
} 