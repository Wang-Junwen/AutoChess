# meta-name: Custom UnitAbility script
# meta-description: 战斗单元施法时实例化
# meta-default: false
# meta-space-indent: 4
class_name _CLASS_
extends UnitAbility

func use() -> void:
	print("可以通过访问 caster：%s 访问BattleUnit" % caster)
	SFXPlayer.play(sound) # 使用该导出变量播放音效
	ability_cast_finished.emit() # 通知战斗系统施法完成
