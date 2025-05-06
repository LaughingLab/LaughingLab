import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:laugh_lab/constants/app_theme.dart';
import 'package:laugh_lab/models/joke_model.dart';
import 'package:laugh_lab/services/joke_service.dart';
import 'package:laugh_lab/services/auth_service.dart';
import 'package:laugh_lab/utils/share_utils.dart';
import 'package:laugh_lab/widgets/comments_section.dart';

class JokeCard extends StatefulWidget {
  final JokeModel joke;

  const JokeCard({super.key, required this.joke});

  @override
  State<JokeCard> createState() => _JokeCardState();
}

class _JokeCardState extends State<JokeCard> {
  bool _isCommentsVisible = false;
  bool? _userRating; // null = no rating, true = upvote, false = downvote
  bool _isRatingLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }
  
  Future<void> _loadUserRating() async {
    final jokeService = Provider.of<JokeService>(context, listen: false);
    final rating = await jokeService.hasUserRatedJoke(widget.joke.id);
    
    if (mounted) {
      setState(() {
        _userRating = rating;
      });
    }
  }
  
  Future<void> _rateJoke(bool isUpvote) async {
    if (_isRatingLoading) return;
    
    final jokeService = Provider.of<JokeService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to rate jokes'),
        ),
      );
      return;
    }
    
    setState(() {
      _isRatingLoading = true;
    });
    
    try {
      await jokeService.rateJoke(widget.joke.id, isUpvote);
      
      if (mounted) {
        setState(() {
          _userRating = isUpvote;
          _isRatingLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRatingLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rating joke: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Joke header with author info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Author avatar
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.5),
                  foregroundColor: AppTheme.primaryColor,
                  child: Text(
                    widget.joke.authorName.isNotEmpty
                        ? widget.joke.authorName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Author name and joke info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.joke.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${timeago.format(widget.joke.createdAt)} • ',
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.secondaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.joke.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Share button
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    ShareUtils.shareJoke(widget.joke);
                  },
                ),
              ],
            ),
          ),
          
          // Joke content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.joke.content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          
          // Divider
          const Divider(),
          
          // Actions row (vote, comment)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Vote count and buttons
                Row(
                  children: [
                    // Upvote button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        color: _userRating == true
                            ? Colors.green
                            : AppTheme.secondaryTextColor,
                      ),
                      onPressed: _isRatingLoading
                          ? null
                          : () => _rateJoke(true),
                    ),
                    
                    // Vote count
                    Text(
                      '${widget.joke.score}',
                      style: TextStyle(
                        color: widget.joke.score > 0
                            ? Colors.green
                            : widget.joke.score < 0
                                ? Theme.of(context).colorScheme.error
                                : AppTheme.secondaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // Downvote button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        color: _userRating == false
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: _isRatingLoading
                          ? null
                          : () => _rateJoke(false),
                    ),
                  ],
                ),
                
                // Comment button and count
                TextButton.icon(
                  icon: Icon(Icons.comment, color: Theme.of(context).colorScheme.onSurface),
                  label: Text(
                    '${widget.joke.commentCount} comments',
                  ),
                  onPressed: () {
                    setState(() {
                      _isCommentsVisible = !_isCommentsVisible;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Comments section (expandable)
          if (_isCommentsVisible)
            CommentsSection(jokeId: widget.joke.id),
        ],
      ),
    );
  }
} 