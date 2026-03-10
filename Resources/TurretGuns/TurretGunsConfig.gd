class_name TurretGunsConfig
extends Resource

## The starting damage to plug into the projectile.
@export var base_damage: float = 20.0

## The starting targeting range of the turret.
@export var base_range: float = 3.0

## The starting area of effect the projectile will be scaled to.
@export var base_aoe: float = 1.0

## The starting essence cost to fire the turret.
@export var base_cost: float = 5.0

## The projectile scene that gets fired when the turret shoots.
@export var projectile: PackedScene