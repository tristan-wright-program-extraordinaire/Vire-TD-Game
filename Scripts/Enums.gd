extends Node

enum Placing {NEXUS,NEST,TURRET,CEMENT}
enum Glyph {BEAM,BALL,SPIN,AREA,PILLAR}

# FIRE_RATE: Essence Cost <-*-> Damage
# DAMAGE_TYPE: Support Damage <-*-> Direct Damage
# IMPACT: Duration <-*-> Range
# TAREGETING: Closest <- First -> Last
enum Stats {FIRE_RATE,DAMAGE_TYPE,IMPACT,TAREGETING}

enum Element {FIRE,WATER,GRASS,ELECTRIC,GROUND}
enum Rewards {TOKEN,KINDLE,TURRET}
enum Rarity {COMMON,RARE,EPIC,LEGENDARY}