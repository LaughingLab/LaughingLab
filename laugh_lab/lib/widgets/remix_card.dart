import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/constants/app_constants.dart';
import 'package:laugh_lab/models/remix_model.dart';
import 'package:laugh_lab/services/remix_service.dart';

class RemixCard extends StatefulWidget {
  final RemixModel remix;
  final String? originalJokeContent;
  final VoidCallback? onTap;
  
  const RemixCard({
    super.key,
    required this.remix,
    this.originalJokeContent,
    this.onTap,
  });

  @override
  State<RemixCard> createState() => _RemixCardState();
}

class _RemixCardState extends State<RemixCard> {
  bool _isVoting = false;
  bool? _userVote;
  
  @override
  void initState() {
    super.initState();
    _loadUserVote();
  }
  
  Future<void> _loadUserVote() async {
    final remixService = Provider.of<RemixService>(context, listen: false);
    final vote = await remixService.getUserVoteOnRemix(widget.remix.id);
    
    if (mounted) {
      setState(() {
        _userVote = vote;
      });
    }
  }
  
  Future<void> _handleUpvote() async {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    try {
      final remixService = Provider.of<RemixService>(context, listen: false);
      await remixService.upvoteRemix(widget.remix.id);
      await _loadUserVote();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }
  
  Future<void> _handleDownvote() async {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    try {
      final remixService = Provider.of<RemixService>(context, listen: false);
      await remixService.downvoteRemix(widget.remix.id);
      await _loadUserVote();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: AppTheme.avatarSizeSmall / 2,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: widget.remix.userPhotoUrl != null
                        ? CachedNetworkImageProvider(widget.remix.userPhotoUrl!)
                        : null,
                    child: widget.remix.userPhotoUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  
                  // User name and post time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.remix.userDisplayName ?? 'Anonymous',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeago.format(widget.remix.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Remix indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.repeat,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Remix',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Original joke content
              if (widget.originalJokeContent != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Original joke:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.originalJokeContent!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Remix content
              Text(
                widget.remix.content,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Actions
              Row(
                children: [
                  // Upvote
                  _buildVoteButton(
                    icon: Icons.thumb_up,
                    count: widget.remix.upvotes,
                    isSelected: _userVote == true,
                    onPressed: _handleUpvote,
                  ),
                  
                  // Downvote
                  _buildVoteButton(
                    icon: Icons.thumb_down,
                    count: widget.remix.downvotes,
                    isSelected: _userVote == false,
                    onPressed: _handleDownvote,
                  ),
                  
                  const Spacer(),
                  
                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${widget.remix.score}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Implement sharing
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildVoteButton({
    required IconData icon, 
    required int count, 
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: _isVoting ? null : onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? icon == Icons.thumb_up
                      ? AppTheme.primaryColor
                      : AppTheme.errorColor
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 