import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:teropong/entities/post.dart';
import 'package:teropong/layouts/deck/list.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  PostDetailPage(this.post, Key? key) : super(key: key);
  @override
  State createState() => PostDetailState();
}

class PostDetailState extends State<PostDetailPage> {
  final PagingController<int, Post> _commentsPagingController =
      PagingController(firstPageKey: 1);

  @override
  Widget build(BuildContext context) {
    return ListDeck(
      featured: widget.post,
      pagingController: _commentsPagingController,
    );
  }

  @override
  void initState() {
    _commentsPagingController.addPageRequestListener((pageKey) {
      widget.post.getReplies();
    });
    super.initState();
  }
}
