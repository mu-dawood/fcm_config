part of web_forground_notification;

class _ForgroundNotificationView extends StatefulWidget {
  final WebNotificationDetails details;
  final VoidCallback? onClick;
  final ValueChanged<int> onDismiss;
  final int id;

  const _ForgroundNotificationView({
    Key? key,
    required this.details,
    this.onClick,
    required this.onDismiss,
    required this.id,
  }) : super(key: key);

  @override
  __ForgroundNotificationViewState createState() =>
      __ForgroundNotificationViewState();
}

class __ForgroundNotificationViewState extends State<_ForgroundNotificationView>
    with TickerProviderStateMixin {
  bool expanded = false;
  bool opened = false;
  bool canExpand = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50)).then((value) async {
      setState(() {
        opened = true;
      });
      await Future.delayed(widget.details.duration);
      if (mounted && !expanded) {
        dismiss();
      }
    });
  }

  void dismiss() async {
    setState(() {
      opened = false;
    });
    await Future.delayed(Duration(milliseconds: 300));
    widget.onDismiss(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositionedDirectional(
      duration: Duration(milliseconds: 300),
      top: opened ? (kIsWeb ? 40 : 20) : -50,
      curve: Curves.easeInCubic,
      start: 20.0,
      end: kIsWeb ? null : 20,
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: kIsWeb ? 500 : 300),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: opened ? 1 : 0,
            child: Dismissible(
              key: Key('fcm_notify'),
              onDismissed: (direction) {
                widget.onDismiss(widget.id);
              },
              child: Card(
                child: InkWell(
                  onTap: () {
                    if (canExpand == true && !expanded) {
                      setState(() {
                        expanded = true;
                      });
                    } else {
                      if (widget.onClick != null) {
                        widget.onClick!();
                      }
                      dismiss();
                    }
                  },
                  child: AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: Duration(milliseconds: 300),
                    vsync: this,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.details.icon != null) widget.details.icon!,
                          if (kIsWeb)
                            buildInner(context)
                          else
                            Expanded(child: buildInner(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column buildInner(BuildContext context) {
    return Column(
      crossAxisAlignment:
          kIsWeb ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.details.title,
          style: Theme.of(context).textTheme.headline6,
        ),
        if (widget.details.subTitle != null)
          Text(
            widget.details.subTitle ?? '',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, size) {
            final span = TextSpan(
              text: widget.details.body,
              style: Theme.of(context).textTheme.bodyText2,
            );
            final tp = TextPainter(
              text: span,
              textDirection: Directionality.of(context),
              maxLines: 1,
            );
            tp.layout(maxWidth: size.maxWidth);
            canExpand = tp.didExceedMaxLines;
            return Text(
              widget.details.body,
              overflow: expanded ? null : TextOverflow.ellipsis,
              maxLines: expanded ? null : 1,
            );
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
