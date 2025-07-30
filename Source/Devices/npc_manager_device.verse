using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }


var NPCManagerMap : weak_map(session,npc_manager_device) = map{}

# Basic npc manager class that tracks npcs and provides utility functions
npc_manager_device := class(creative_device):

    var Agents : []agent = array{}

    @editable
    NpcSpawners : []guard_spawner_device = array{}

    OnBegin<override>():void=
        if:
            set NPCManagerMap[GetSession()] = Self

        for:    
            NpcSpawner : NpcSpawners
        do:
            NpcSpawner.SpawnedEvent.Subscribe(AddToAgents)
            NpcSpawner.EliminatedEvent.Subscribe(RemoveFromAgents)   

    GetEnemiesInRadius(Position : vector3, Radius : float):[]agent=
        for:
            Agent : Agents
            Distance(Position,Agent.GetFortCharacter[].GetTransform().Translation) <= Radius
        do:
            Agent

    AddToAgents(Agent : agent):void=
        set Agents += array{Agent}
        
    RemoveFromAgents(InteractionResult : device_ai_interaction_result):void=
        if:
            Target := InteractionResult.Target?
            NewAgents := Agents.RemoveAllElements(Target)
            set Agents = NewAgents