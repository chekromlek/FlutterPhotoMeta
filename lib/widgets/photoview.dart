import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterphotometa/fullphoto.dart';
import 'package:flutterphotometa/protobuf/photo.pb.dart';
import 'package:flutterphotometa/widgets/hero.dart';
import 'package:flutterphotometa/widgets/metadata.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class FullPhotoView extends StatefulWidget {
  final String tag;
  final Widget child;
  final PhotoMetadataWidget metadata;
  final double initTop;
  final GlobalKey metaKey;
  final Photo photo;

  FullPhotoView(
      {this.tag,
      this.child,
      this.photo,
      this.metadata,
      this.initTop,
      this.metaKey})
      : super();

  @override
  State<StatefulWidget> createState() {
    return _FullPhotoViewState();
  }
}

class _FullPhotoViewState extends State<FullPhotoView>
    with TickerProviderStateMixin {
  Offset _translateFromScene;
  Matrix4 _transform = Matrix4.identity();
  double _top;

  Animation<double> _topAnimation;
  AnimationController _controller;

  Size get _containerSize {
    final RenderBox containerRenderBox =
        widget.metaKey.currentContext.findRenderObject();
    return containerRenderBox.size;
  }

  Matrix4 get _initialTransform {
    return Matrix4.identity();
  }

  static Offset fromViewport(double dy, Matrix4 transform) {
    final Matrix4 inverseMatrix = Matrix4.inverted(transform);
    final Vector3 untransformed = inverseMatrix.transform3(Vector3(
      0,
      dy,
      0,
    ));
    return Offset(untransformed.x, untransformed.y);
  }

  static Offset getOffset(BuildContext context) {
    final RenderBox renderObject = context.findRenderObject();
    return renderObject.localToGlobal(Offset.zero);
  }

  Tween<Rect> heroRect(Rect begin, Rect end) {
    return RectTween(begin: begin, end: computeDesitnationBound(widget.photo, FullPhoto.safeAreaKey));
  }

  Matrix4 matrixTranslate(Matrix4 matrix, double dy) {
    final Matrix4 nextMatrix = matrix.clone()
      ..translate(
        0.0,
        dy,
      );
    return nextMatrix;
  }

  @override
  void initState() {
    super.initState();
    _top = widget.initTop;
    _transform = _initialTransform;

    _controller = AnimationController(vsync: this);
  }

  void _onAnimate() {
    setState(() {
      _transform = matrixTranslate(_transform, _topAnimation.value - _top);
      _top = _topAnimation.value;
    });
    if (!_controller.isAnimating) {
      _topAnimation?.removeListener(_onAnimate);
      _topAnimation = null;
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        if (_controller.isAnimating) {
          _controller.stop();
          _controller.reset();
          _topAnimation = null;
        }
        setState(() {
          _translateFromScene = fromViewport(
              details.globalPosition.dy - getOffset(context).dy, _transform);
        });
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          if (_translateFromScene != null) {
            double delta = details.primaryDelta;
            _top += delta;
            final minY = widget.initTop - _containerSize.height;
            if (_top < minY) {
              delta -= _top - (widget.initTop - _containerSize.height);
              _top = minY;
            } else if (_top > widget.initTop) {
              delta -= _top - widget.initTop;
              _top = widget.initTop;
            }
            _transform = matrixTranslate(_transform, delta);
            _translateFromScene = fromViewport(delta, _transform);
          }
        });
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _translateFromScene = null;
        });

        _topAnimation?.removeListener(_onAnimate);
        _controller.reset();

        if (_top == widget.initTop ||
            _top == widget.initTop - _containerSize.height) {
          // nothing to do here. All widget is properly in places.
          return;
        }

        double newTop;
        if (details.primaryVelocity < 0) {
          newTop = widget.initTop - _containerSize.height;
        } else {
          newTop = widget.initTop;
        }

        final duration = (details.primaryVelocity / (newTop - _top)).abs();
        _topAnimation = Tween<double>(
          begin: _top,
          end: newTop,
        ).animate(_controller);

        _controller.duration = Duration(milliseconds: duration.toInt());
        _topAnimation.addListener(_onAnimate);
        _controller.fling();
      },
      onVerticalDragCancel: () {
        print("cancel");
      },
      child: Stack(children: <Widget>[
        Positioned.fill(
          child: Hero(
              tag: widget.tag,
              createRectTween: heroRect,
              child: Transform(
                transform: _transform,
                child: widget.child,
              )),
        ),
        Positioned(
          top: _top,
          left: 0,
          right: 0,
          child: widget.metadata,
        ),
      ]),
    );
  }
}
