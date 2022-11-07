import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:teropong/entities/post.dart';

class ListDeck extends StatefulWidget {
  final Post? featured;
  final PagingController<int, Post> pagingController;
  final List<Post>? postList;
  final ScrollController? scrollController;
  const ListDeck({
    this.featured,
    super.key,
    required this.pagingController,
    this.postList,
    this.scrollController,
  });

  @override
  State<ListDeck> createState() => ListDeckState();
}

class ListDeckState extends State<ListDeck> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        widget.pagingController.refresh();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text("🔭 go explore the fediverse!"),
        ),
        body: Stack(
          children: [
            CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                if (widget.featured != null)
                  SliverToBoxAdapter(
                    child: widget.featured!.buildCard(context),
                  ),
                if (widget.featured != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Replies",
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                // if (widget.featured != null)
                //   SliverToBoxAdapter(
                //     child: Divider(),
                //   ),
                PagedSliverList(
                  builderDelegate: PagedChildBuilderDelegate<Post>(
                      itemBuilder: (context, item, index) =>
                          item.buildCard(context)),
                  pagingController: widget.pagingController,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Create something",
                            prefixIcon: IconButton(
                              icon: const Icon(FluentIcons.emoji_24_regular),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(FluentIcons.attach_24_regular),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                      ),
                    ),
                    const SizedBox(width: 3),
                    FloatingActionButton(
                      onPressed: () {},
                      child: Icon(FluentIcons.send_24_regular),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
