# 绘图画布网格修复（最小改动）

这个补丁只处理两个真实缺陷，不包含主题、抽屉、设置页或便签外观改动：

1. 坐标轴与网格原点不一致；
2. 点阵画布卡顿。

## 不包含的改动

- 不新增抽屉关闭按钮；
- 不修改“界面”设置分组；
- 不替换“深色主题”开关；
- 不修改便签卡片的颜色、容器或排版；
- 不引入新的整体主题或 Material 组件样式。

## 接入方式

### 1. 替换绘图背景 painter

在 `lib/workbench.dart` 中，把 `_InfiniteCanvasBackgroundPainter` 替换为 `DrawingCanvasGridPainter`：

```dart
DrawingCanvasGridPainter(
  style: switch (canvasStyle) {
    'dots' => DrawingCanvasGridStyle.dots,
    'grid' => DrawingCanvasGridStyle.grid,
    _ => DrawingCanvasGridStyle.none,
  },
  gridColor: gridColor,
  axisColor: axisColor,
  spacing: 48,
  majorEvery: 5,
  devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
)
```

新 painter 的关键行为：

- 以 `size.center` 为唯一原点；
- 网格线和坐标轴共用 48px spacing；
- 点阵和网格共用同一坐标系统；
- 点阵使用缓存 tile + `ImageShader`，一次 `drawPaint` 铺满，避免上万次圆点栅格化；
- 网格使用缓存 `Float32List` + `drawRawPoints`。

### 2. 背景加 RepaintBoundary

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: DrawingCanvasGridPainter(...),
    isComplex: true,
    willChange: false,
    size: Size.infinite,
  ),
)
```

### 3. 拖动笔迹不要再 setState 整个绘图页

反汇编确认 `_DrawingWorkbenchState::_updateStroke` 的画笔分支每次 pointer move 都会 `setState`。这会重建整个绘图页，点阵背景也会跟着重新栅格化。

建议：

```dart
class _WorkbenchDrawingPainter extends CustomPainter {
  _WorkbenchDrawingPainter(
    /* existing params */, {
    required Listenable repaint,
  }) : super(repaint: repaint);
}
```

`_updateStroke` 修改点集后只通知重绘：

```dart
_liveStrokeRepaint.notifySoon();
```

只在笔画开始/结束、撤销/重做、工具或背景切换时调用 `setState`。

## 验证

- 网格模式下，中心横向/纵向轴线必须落在网格交点上；
- 切换 grid / dots 时，图案相位不跳变；
- 大画布点阵模式下拖动笔迹，帧率应明显稳定；
- 100% 与 200% 字体缩放下不影响绘图坐标。
