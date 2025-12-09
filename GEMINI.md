# {{ 自走棋 }} - AI 协作配置

## 📋 项目概览
- **项目类型**: Godot引擎实现像素风的自走棋游戏，类似云顶之弈、 刀塔自走棋。
- **核心目标**: 该项目只实现具体玩法，包含刷新、购买英雄的商店系统，英雄合并升级、放置英雄战斗，敌人和英雄的战斗AI，英雄各自的属性，及羁绊系统等等

## 🛠 技术栈
- **游戏引擎**: Godot4.4

## 📝 开发规范
### 代码风格
- 使用VScode插件 DoHe.godot-format 进行格式化。
- 编程规范遵循GDScript官方文档。

### 文件结构
- 资源文件放在`assets/`下
- 按功能模块划分文件夹，如 `scene/arena`、`components/` 等。
- 每个模块内按文件类型划分，如 `*.gd`、`*.tscn`、`*.res` 等。

## 🤖 AI 助手配置
### 角色定义
你是一个资深的Godot游戏开发工程师，精通本项目使用的技术栈。

### 沟通语气
- **教学导向**: 解释为什么这样做，不只是怎样做。
- **实用主义**: 提供可直接使用的解决方案。
- **简洁明了**: 避免冗长的解释。

## 💡 常见任务示例
### 示例1：添加一个新的 API 端点
**用户问题**: "我需要实现一个拖拽和放置功能的组件，之后可以添加到任何需要拖拽的物体上。"
**期望回答**: "为了实现拖拽和放置功能，我们可以在`components/`下创建 `components/drag_and_drop.gd` 文件，用于实现通用 2D 拖放功能。它的设计目标是“组合优于继承”，可以挂载到任何 Area2D 节点上赋予其拖拽能力，同时处理了 Z轴排序（防止遮挡）、拖拽偏移（手感更自然）以及 全局输入捕获（防止鼠标甩飞丢失状态）等细节问题。具体代码和逻辑分析如下：

```gdscript
class_name DragAndDrop
extends Node

signal drag_canceled(starting_position: Vector2)
signal drag_started
signal dropped(starting_position: Vector2)

@export var enabled: bool = true
@export var target: Area2D

var starting_position: Vector2
var offset := Vector2.ZERO
var dragging: bool = false


func _ready() -> void:
	assert(target, "No target set for DragAndDrop")
	# unbind(1) 会忽略掉这个信号连接的最后一个参数shape_idx
	target.input_event.connect(_on_target_input_event.unbind(1))


func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset


func _input(event: InputEvent) -> void:
	# 取消拖拽 和 放下，需要放到input中，鼠标移动过快时，有可能鼠标没有点击到target上
	if dragging and event.is_action_pressed("cancel_drag"):
		_cancel_dragging()
	elif dragging and event.is_action_released("select"):
		_drop()


func _start_dragging() -> void:
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	target.z_index = 99
	offset = target.global_position - target.get_global_mouse_position()
	drag_started.emit()


func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")
	target.z_index = 0


func _cancel_dragging() -> void:
	_end_dragging()
	drag_canceled.emit(starting_position)


func _drop() -> void:
	_end_dragging()
	dropped.emit(starting_position)


func _on_target_input_event(_viewport: Node, event: InputEvent) -> void:
	if not enabled:
		return

	var dragging_object = get_tree().get_first_node_in_group("dragging")
	if not dragging and dragging_object:
		return

	if not dragging and event.is_action_pressed("select"):
		_start_dragging()
```

核心逻辑解析

  1. 信号 (Signals)
   * drag_started: 拖拽开始时发出。
   * drag_canceled(starting_position): 拖拽中途被取消（如按下右键）时发出，并传回拖拽前的原始位置以便复位。
   * dropped(starting_position): 拖拽正常结束（松开左键）时发出，传回起始位置。接收者通常会判断放下位置是否有效，如果无效则利用这个 starting_position
     进行复位。

  2. 状态变量
   * target: 被拖拽的 Area2D 节点（通常是棋子）。
   * dragging: 当前是否正在被拖拽。
   * starting_position: 记录拖拽开始前的坐标，用于“悔棋”或无效放置后的归位。
   * offset: 鼠标点击位置与物体中心的偏移量，确保拖拽时物体不会瞬间跳变到鼠标中心，保持抓取点的相对位置。

  3. 输入处理流程

   * 开始拖拽 (`_on_target_input_event`):
       * 通过 target.input_event 监听鼠标在物体上的点击。
       * 当按下 "select" (通常是左键) 时触发。
       * 检查 dragging 组，确保同一时间只能拖拽一个物体。
       * 调用 _start_dragging():
           * 记录 starting_position。
           * 计算并保存 offset。
           * 将物体加入 dragging 组。
           * 提高 z_index 到 99，确保拖拽中的物体显示在最上层。
           * 发送 drag_started 信号。

   * 拖拽中 (`_process`):
       * 每一帧更新 target 的位置：鼠标位置 + offset。
       * 这实现了物体紧跟鼠标移动。

   * 结束/取消拖拽 (`_input`):
       * 使用全局 _input 而不是局部 _input_event，防止鼠标移动太快移出物体范围后无法接收到松开或取消事件。
       * 取消: 按下 "cancel_drag" (通常是右键)，调用 `_cancel_dragging()`，复位状态并发送 `drag_canceled`。
       * 放下: 松开 "select" (左键)，调用 _drop()，复位状态并发送 dropped。"