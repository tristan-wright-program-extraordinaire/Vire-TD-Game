extends RewardButton

@onready var glyph_label: Label = %GlyphLabel
@onready var rarity_label: Label = %RarityLabel
@onready var array_label: Label = %ArrayLabel


func _update_labels(new_reward) -> void:
	print(new_reward.rarity)
	glyph_label.text = ENUMS.Glyph.find_key(new_reward.glyph)
	rarity_label.text = ENUMS.Rarity.find_key(new_reward.rarity)
	new_reward.empowered_stats.sort()
	var array_text = []
	for stat in new_reward.empowered_stats:
		array_text.append(ENUMS.Stats.find_key(stat))
	array_label.text = str("\n".join(array_text))

