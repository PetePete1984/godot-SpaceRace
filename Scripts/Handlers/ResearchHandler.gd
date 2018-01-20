extends Node
var ResearchProject = preload("res://Scripts/Model/ResearchProject.gd")

func start_research(player, technology):
    var started = false
    if not technology in player.completed_research:
        var resDef = ResearchDefinitions.research_defs[technology]
        var project = ResearchProject.new()
        project.research = technology
        project.remaining_research = resDef.cost
        project.initial_cost = resDef.cost
        player.research_project = project
        player.research[technology] = project
        started = true
    return started

func finish_research_project(player):
    var technology = player.research_project.research
    player.completed_research.append(technology)
    player.research[technology].remaining_research = 0
    player.research_project = null
    pass

func instant_research(player, technology):
    if player.research_project != null:
        if player.research_project.research == technology:
            finish_research_project(player)
            return
    
    player.completed_research.append(technology)
    pass

func finish_random_research(player):
    var available = []
    for tech in ResearchDefinitions.research_defs.keys():
        if not tech in player.completed_research:
            available.append(tech)

    var pick = Utils.rand_pick_from_array(available)
    instant_research(player, pick)
    return pick