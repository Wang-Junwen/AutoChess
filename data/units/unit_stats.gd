class_name UnitStats
extends Resource

enum Rarity {
    COMMON,
    UNCOMMON,
    RARE,
    LEGENDARY
}

const RARITY_COLORS = {
    Rarity.COMMON: Color("124a2e"), # 深绿色
    Rarity.UNCOMMON: Color("1c527c"), # 深蓝色
    Rarity.RARE: Color("ab0979"), # 紫色
    Rarity.LEGENDARY: Color("ea940b") # 橙色
}


@export var name: String

@export_category("Data")
@export var rarity: Rarity
@export var gold_cost := 1

@export_category("Visuals")
@export var skin_coordinates: Vector2i