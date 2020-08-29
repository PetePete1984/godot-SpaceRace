# special ability definition
extends Reference

var spec_name = ""
var spec_cooldown = 0
var spec_function = null
var spec_passive = false
var spec_description = ""

# special abilities
# minions
#  invasions always succeed
#  SA_SuperMarines
# snovemdomas
#  ship hull strength doubled
#  SA_DoubleHull
# orfa
#  black squares function like white squares
# kambuchka
#  see all home stars
#  SA_KnowHomeWorlds
# hanshaks
#  all races visible in diplomacy
#  SA_KnowRaces
# fludentri
#  60 days: repair all ship damage
#  SA_HealShips
# baliflids
#  100 days: enforce peace with all races
#  SA_ForcePeace
# swaparamans
#  62 days: double ship power
#  SA_DoublePower
# frutmaka
#  77 days: warp other ships out of systems
#  SA_RepelAlienShips
# shevar
#  90 days: drain other ship energy in any system (test if all systems)
#  Special Abilities are only usable on the galaxy screen, so this is actually interesting
#  SA_SapAlienPower
# govorom
#  150 days: least pop'd world becomes rich
#  SA_Cornucopia
# ungooma
#  70 days: reset ship lane progress
#  SA_BumpShipsInLanes
# dubtaks
#  63 days: steal tech owned by 2+ races
#  SA_StealResearch
# capelons
#  66 days: colonies invincible for 1 turn
#  SA_ShieldPlanets
# mebes
#  72 days: max pop on all colonies increased (1 or 2?)
#  SA_MoreMaxPop
# oculons
#  see all star lanes
#  SA_KnowStarLanes
# arbryls
#  100 days: close all lanes in own systems (or occupied, too?) (applies lane blocker)
#  SA_BlockStarLanes
# marmosians
#  100 days: divert hostility
#  SA_CauseWar
# chronomyst
#  double star lane speed
#  SA_FastLaneTravel
# chamachies
#  89 days: complete research immediately
#  SA_FreeResearch
# nimbuloids
#  68 days: boost industry for a day (doubled?)
#  SA_IndustryBoost