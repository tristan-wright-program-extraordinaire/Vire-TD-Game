extends RewardButton

@onready var stat_label: Label = %StatLabel
@onready var rarity_label: Label = %RarityLabel

func _update_labels(new_reward) -> void:
	print(new_reward.rarity)
	stat_label.text = ENUMS.Stats.find_key(new_reward.empowered_stat)
	rarity_label.text = ENUMS.Rarity.find_key(new_reward.rarity)
