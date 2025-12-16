# Deck Builder Practice for Godot（像素杀戮尖塔练习）
A roguelike deckbuilder practice project made in Godot 4.

# Note
## Preloads带来的循环引用问题
当打完boss，重新开始游戏，选择角色后点击start，然后报错：Failed to instantiate scene state of \"%s\", node count is 0. Make sure the PackedScene resource is valid无法进入Run场景。神奇的是，当我运行时加了句print打印日志保存后，再点击开始就正常进入到Run场景了。
或者我不采用const RUN_SCENE = preload("uid://bbk3xah3s5r6y")预加载而是直接通过get_tree().change_scene_to_file("res://scenes/run/run.tscn")切换点击start进入run就不会有问题
### 解决方案
- [Do not use preload](https://theduriel.github.io/Godot/Do-not-use---Preload)
[reddit问题](https://www.reddit.com/r/godot/comments/1ot6h51/cant_go_back_to_a_scene_failed_to_instantiate/)

## 资源深拷贝问题
对卡组进行duplicate(true)时，卡组内部数组内的卡牌资源并未进行深拷贝
### 分析
- 资源深拷贝失效的问题是因为duplicate(true)在面对数组字典内包含非局部(共享)的资源时不会进行深拷贝，因此需要改成调用duplicate_deep(Resource.DEEP_DUPLICATE_ALL)通过参数告诉godot你的真实意图，新复制的卡牌将不再是共享资源
但是由于，这个卡组内
- 但是deck pile和draw pile虽然是独立的资源，但是draw pile内部的同类型卡牌还是会引用相同的资源，因为duplicate_deep会保持复制前的内部数组引用关系，防止重复创建，因为如若彻底解决还是得按照作者的方法（如下），对每个卡牌单独duplicate或者就是去卡牌池里将数组内的所有卡牌都右键点击唯一化
- [closed issue](https://github.com/godotengine/godot/pull/100673)

```GDScript
# We need this method because of a Godot issue reported here:
# https://github.com/godotengine/godot/issues/74918
func duplicate_cards() -> Array[Card]:
	var new_array: Array[Card] = []
	for card: Card in cards:
		new_array.append(card.duplicate())
	return new_array


# We need this method because of a Godot issue reported here:
# https://github.com/godotengine/godot/issues/74918
func custom_duplicate() -> CardPile:
	var new_card_pile := CardPile.new()
	new_card_pile.cards = duplicate_cards()
	return new_card_pile
```

## 小问题
- `child_order_changed`：信号很危险，场景销毁时也会调用，需要在接收方判断`is_inside_tree()`或`is_instance_valid(node)`（见`battle.gd`, `relic_control.gd`）
- 单目标卡牌aim时发现与下方hbox内的卡牌未对齐，因为hbox安排的子坐标都是整数（甚至你选择Center但是为了整数对齐，并不完全中心对称），因此aim的卡牌所放位置也要是整数（见`card_aim_state.gd`）
- setter内部如要连接信号，一般需要判断是否连接，没连接才会进行连接：
```GDScript
if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
```
- queue_free()会在帧末尾销毁，如果需要立即销毁可以调用free()
- 导出变量如果的setter函数如果需要访问节点，需要判断节点是否初始化完成：
```GDScript
func _set_card(value: Card) -> void:
	# 因为导出变量可能在项目运行时节点尚未加入场景树前被赋值
	if not is_node_ready():
		await ready
	# ...
```

# Credits
- [from repository](https://github.com/guladam/deck_builder_tutorial/tree/season-2-starter-project)
- [ko-fi](https://ko-fi.com/M4M0RXV24)
- [Ben from Heartbeast](https://www.youtube.com/@uheartbeast): he originally started working on this project. He gave me permission, inspiration and also great ideas for this tutorial.
- [Kenney](https://kenney.nl)'s tiny dungeon asset pack
- Sound effects:
  - [StarNinjas](https://opengameart.org/users/starninjas) from OpenGameArt 
  - [Pixabay](https://pixabay.com/sound-effects/shield-guard-6963/) 
  - [artisticdude](https://opengameart.org/users/artisticdude) from OpenGameArt
- Music made by [Tad](https://www.youtube.com/c/Tadon)
