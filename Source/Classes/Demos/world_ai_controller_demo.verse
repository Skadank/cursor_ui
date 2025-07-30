using { /Fortnite.com/AI }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { Textures }


controllable_ai := class(npc_behavior):

    var DirectionManager : menu_manager_device = menu_manager_device{}
    var NpcManager : npc_manager_device = npc_manager_device{}

    OnBegin<override>()<suspends>:void=
        Print("It's alive...")
        if:
            M := MenuManagerMap[GetSession()]
            set DirectionManager = M
        
        if:
            M := NPCManagerMap[GetSession()]
            set NpcManager = M

        if:
            Agent := GetAgent[]
            FC := Agent.GetFortCharacter[]
            Navigatable := FC.GetNavigatable[]
            Focus := FC.GetFocusInterface[]
        then:
            sync:
                loop:
                    NewPosition := DirectionManager.MoveEvent.Await()
                    spawn{HandleMovement(NewPosition,Focus,Navigatable)}
                loop:
                    TargetPosition := DirectionManager.TargetEvent.Await()
                    spawn{HandleProjectile(TargetPosition, FC)}

    HandleMovement(NewPosition : vector3, Focus : focus_interface, Navigatable : navigatable)<suspends>:void=
        Print("Heading to {ToString(NewPosition)}")
        NavTarget := MakeNavigationTarget(NewPosition)
        if:
            Prop := SpawnProp(DirectionManager.MovementProp,NewPosition,IdentityRotation())(0)?
        then:
            race:
                DirectionManager.MoveEvent.Await()
                Focus.MaintainFocus(NewPosition + vector3{Z:=96.0})
                Navigatable.NavigateTo(NavTarget, ?MovementType:=movement_types.Walking)
            Prop.Dispose()

    HandleProjectile(TargetPosition : vector3, FC : fort_character)<suspends>:void=
        PlayerPosition := FC.GetTransform().Translation
        if:
            DirectionVector := ((TargetPosition + vector3{Z:=PlayerPosition.Z}) - PlayerPosition).MakeUnitVector[]
        then:
            ProjectileSpawn := PlayerPosition + (DirectionVector * 50.0)
            ProjectileDestination := PlayerPosition + (DirectionVector * 2000.0)
            if:
                Prop := SpawnProp(DirectionManager.Projectile,ProjectileSpawn,IdentityRotation())(0)?
            then:
                sync:
                    Prop.MoveTo(ProjectileDestination,IdentityRotation(),2.0)
                    loop:
                        Sleep(0.0)
                        EnemiesHit := NpcManager.GetEnemiesInRadius(Prop.GetTransform().Translation, 80.0)
                        for:
                            EnemyHit : EnemiesHit
                            EnemyFC := EnemyHit.GetFortCharacter[]
                        do:
                            EnemyFC.Damage(100.0)

                Prop.Dispose()

world_ai_controller_menu := class(cursor_menu):

    RightClickInput : input_trigger_device

    MovementEvent : event(vector3)
    TargetEvent : event(vector3)

    MoveCursor<override>(NewPosition : vector2):void=
        Cursor.SetPosition(NewPosition)

    (Agent : agent).ClickHandler<override>()<suspends>:void=
        sync:
            loop:
                Clicker := LeftClickInput.PressedEvent.Await()
                if:
                    Clicker = Agent
                then:
                    CursorPosition := Cursor.GetPosition()
                    WorldPosition := vector3{X:=CursorPosition.X, Y:=1080.0 - CursorPosition.Y,Z:=0.0}
                    MovementEvent.Signal(WorldPosition)
            loop:
                Clicker := RightClickInput.PressedEvent.Await()
                if:
                    Clicker = Agent
                then:
                    CursorPosition := Cursor.GetPosition()
                    WorldPosition := vector3{X:=CursorPosition.X, Y:=1080.0 - CursorPosition.Y,Z:=0.0}
                    TargetEvent.Signal(WorldPosition)

    Init<override>(Agent : agent):void=
        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Agent.ClickHandler()}

    BuildCanvas<override>():canvas=canvas{}