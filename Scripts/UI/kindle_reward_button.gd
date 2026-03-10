extends RewardButton

@onready var element_label: Label = %ElementLabel
@onready var rarity_label: Label = %RarityLabel
@onready var amount_label: Label = %AmountLabel

func _update_labels(new_reward) -> void:
	element_label.text = ENUMS.Element.find_key(new_reward.element)
	rarity_label.text = ENUMS.Rarity.find_key(new_reward.rarity)
	amount_label.text = str(new_reward.amount)
