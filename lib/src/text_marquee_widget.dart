import 'package:flutter/widgets.dart';

class TextMarqueeWidget extends StatelessWidget {
  final Widget child;

  final double spacing;

  final Duration? duration;

  final Duration? delay;

  final bool rtl;

  const TextMarqueeWidget({
    super.key,
    required this.child,
    this.spacing = 36,
    this.duration,
    this.delay,
    this.rtl = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _MarqueeText(
          width: constraints.maxWidth,
          spacing: spacing,
          delay: delay,
          duration: duration,
          rtl: rtl,
          child: child,
        );
      },
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final Widget child;

  final double width;

  final double spacing;

  final Duration? duration;

  final Duration? delay;

  final bool rtl;

  const _MarqueeText(
      {required this.child,
      required this.width,
      this.spacing = 36,
      this.duration,
      this.delay,
      required this.rtl});

  @override
  State<_MarqueeText> createState() => __MarqueeTextState();
}

class __MarqueeTextState extends State<_MarqueeText> {
  final ScrollController controller = ScrollController();

  double _widgetWidth = 0;

  bool allowScrolling = false;

  bool isScrolling = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (controller.hasClients) {
          if (mounted) {
            setState(() {
              allowScrolling = controller.position.maxScrollExtent > 0;
            });
          }

          _widgetWidth = controller.position.maxScrollExtent + widget.width;

          _startAnimation();
        }
      });
    });

    super.initState();
  }

  Future<void> _startAnimation() async {
    if (isScrolling) return;

    if (allowScrolling) {
      final scrollLength = _widgetWidth + widget.spacing;

      if (controller.hasClients) {
        await controller
            .animateTo(
          scrollLength,
          duration: widget.duration ??
              Duration(milliseconds: (scrollLength * 27).toInt()),
          curve: Curves.linear,
        )
            .then(
          (value) async {
            isScrolling = false;

            if (controller.hasClients) {
              controller.jumpTo(0);
            }

            if (widget.delay != null) await Future.delayed(widget.delay!);

            _startAnimation();
          },
        );
      }

      isScrolling = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SingleChildScrollView(
        reverse: widget.rtl,
        padding: EdgeInsets.zero,
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            widget.child,
            if (allowScrolling) SizedBox(width: widget.spacing),
            if (allowScrolling) widget.child
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
