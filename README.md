# 简单自走棋
 该项目是一个使用 Godot 4 开发的自走棋游戏。主要代码结构如下：

   * `scene/`: 包含游戏的主要场景。
       * scene/arena/: 包含竞技场相关的逻辑 (arena.gd) 和场景 (arena.tscn)。
       * scene/unit/: 包含单位相关的逻辑 (unit.gd) 和场景 (unit.tscn)。
   * `components/`: 包含可复用的组件脚本。
       * drag_and_drop.gd: 处理单位拖拽。
       * unit_grid.gd: 管理网格上的单位数据。
       * unit_combiner.gd: 处理单位合并升级逻辑。
       * velocity_based_rotation.gd: 处理基于速度的旋转。
       * outline_highlighter.gd: 处理描边高亮。
   * `data/`: 包含游戏数据。
       * data/units/: 包含单位属性定义 (unit_stats.gd) 和具体单位数据 (bjorn.tres 等)。
   * `assets/`: 包含美术和音频资源。




### Credits
- [32rogues asset pack by Seth](https://sethbb.itch.io/32rogues)
- [Kenney](https://kenney.nl/assets/cursor-pixel-pack)'s cursor pixel pack
- Sound effects are from the [Soniss GDC 2024 Game Audio Bundle](https://gdc.sonniss.com/)
- [StarNinjas](https://opengameart.org/users/starninjas) (sound effects)
- [remaxim](https://opengameart.org/users/remaxim) (sound effects)
- Music made by [Alexander Ehlers](https://opengameart.org/users/tricksntraps)
- [m5x7 font](https://managore.itch.io/m5x7) by Daniel Linssen
- [Abaddon font](https://caffinate.itch.io/abaddon) by Nathan Scott
