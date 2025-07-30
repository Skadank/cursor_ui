using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }


var MenuManagerMap : weak_map(session,menu_manager_device) = map{}

menu_manager_device := class(creative_device):


    # --------------------General Fields-----------------
    @editable
    LeftClickInput : input_trigger_device = input_trigger_device{}

    @editable
    RightClickInput : input_trigger_device = input_trigger_device{}

    @editable
    DemoButtons : []button_device = array{}

    RemoveUIEvent : event(player) = event(player){}
    # ----------------------------------------------------------


    # --------------------Target Shooter Fields-----------------
    @editable
    TargetTimer : timer_device = timer_device{}

    @editable
    HitAudio : audio_player_device = audio_player_device{}

    @editable
    GameOverAudio : audio_player_device = audio_player_device{}
    # ----------------------------------------------------------

    
    # --------------------World Related Fields-----------------
    
    @editable
    HoverCinematic : cinematic_sequence_device = cinematic_sequence_device{}

    @editable
    WorldObjects : []world_object = array{}

    # For the world merge game (index is the tier of mergeable)
    @editable
    PropAssets : []creative_prop_asset = array{}

    # ----------------------------------------------------------


    # --------------------Bomber Related Fields-----------------

    @editable
    Explosive : explosive_device = explosive_device{}

    # ----------------------------------------------------------

    # --------------------Merge Game Fields-------------------- 

    @editable
    MergeSound :audio_player_device = audio_player_device{}

    # ----------------------------------------------------------

    # --------------------NPC related fields-------------------- 
    # Movement indicator of the controllable npc (circle on ground)
    @editable
    MovementProp : creative_prop_asset = DefaultCreativePropAsset

    @editable
    Projectile : creative_prop_asset = DefaultCreativePropAsset

    MoveEvent : event(vector3) = event(vector3){}
    TargetEvent : event(vector3) = event(vector3){}
    # ----------------------------------------------------------

    # Fields from @JaireWho's spatial math code,
    # Forgot to make these per player when porting his stuff over
    # TODO: Make these per player
    var LastCameraRotation : rotation = rotation{}
    var CursorX : float = 0.0
    var CursorY : float = 0.0
    var LastPitch : float = 0.0
    Sensitivity : float = 2.0
    ScreenSize : vector2 = vector2{X:=1920.0,Y:=1080.0}

    OnBegin<override>()<suspends>:void=
        if:
            set MenuManagerMap[GetSession()] = Self
        for:
            Index -> DemoButton : DemoButtons
        do:
            DemoButton.InteractedWithEvent.Subscribe(callBack(int){Arg:=Index, Func:=StartDemo}.Invoke)

    StartDemo(Agent : agent,DemoIndex : int):void=
        if:
            Player := player[Agent]
        then:
            spawn{HandleDemo(Player, DemoIndex)}
   
    HandleDemo(Player: player, DemoIndex : int)<suspends>:void=
        CursorMenu : cursor_menu = case (DemoIndex):
            0 => crafting_menu{RemoveUIEvent:=RemoveUIEvent,LeftClickInput:=LeftClickInput}
            1 => {
                HoverCinematic.Play(Player)   
                world_editor_menu{RemoveUIEvent:=RemoveUIEvent,UIElements:=WorldObjects,LeftClickInput:=LeftClickInput}
            } 
            2 => {
                HoverCinematic.Play(Player)   
                world_bomber_menu{RemoveUIEvent:=RemoveUIEvent,Explosive:=Explosive,LeftClickInput:=LeftClickInput}
            }
            3 => {
                HoverCinematic.Play(Player)   
                world_ai_controller_menu{RemoveUIEvent:=RemoveUIEvent,MovementEvent:=MoveEvent,TargetEvent:=TargetEvent,LeftClickInput:=LeftClickInput,RightClickInput:=RightClickInput}
            } 
            4 => {
                HoverCinematic.Play(Player)   
                world_merge_menu{RemoveUIEvent:=RemoveUIEvent,MergeSound:=MergeSound,PropAssets := PropAssets, LeftClickInput:=LeftClickInput}
            }
            5 => merge_menu{RemoveUIEvent:=RemoveUIEvent,MergeSound:=MergeSound,LeftClickInput:=LeftClickInput}
            _ => target_game_menu{RemoveUIEvent:=RemoveUIEvent,Timer:=TargetTimer,HitSound:=HitAudio,GameOverSound:=GameOverAudio,LeftClickInput:=LeftClickInput, Player :=Player}

        CursorMenu.Init(Player)
        if:
            FC := Player.GetFortCharacter[]
        then:
            CursorMenu.AddToPlayer(Player, false)
            Pos := FC.GetTransform().Translation
            if:
                FC.TeleportTo[Pos, IdentityRotation()]
            then:
                FC.PutInStasis(stasis_args{AllowTurning:=true})

            Sleep(0.1)
            set PlaneLocation = FC.GetTransform().Translation + (FC.GetViewRotation().GetLocalForward() * 1500.0)
            loop:
                NewPos := GetCursorPosition(FC)
                CursorMenu.MoveCursor(NewPos)
                Sleep(0.0)

    # Code by @JaireWho, very clever guy, he does some pretty cool stuff, check out his work https://x.com/JaireWho
    GetCursorPosition(FC : fort_character): vector2 =
        CurrentRotation:= FC.GetViewRotation()
        YawDelta:= GetYawDelta(CurrentRotation, LastCameraRotation)
        CurrentPitch:= GetPitchFromRotation(CurrentRotation)
 
        var PitchDelta: float = 0.0
        if. CurrentPitch <> LastPitch then:
            set PitchDelta = CurrentPitch - LastPitch
            set LastPitch = CurrentPitch
 
        set CursorX = Clamp(CursorX + (YawDelta * (ScreenSize.X / 360.0) * Sensitivity), 0.0, ScreenSize.X)
        set CursorY = Lerp(0.0, ScreenSize.Y, (((CurrentPitch + 90.0) * 2.0) / 180.0))
 
        set LastCameraRotation = CurrentRotation
 
        CurrentPos:= vector2{X:= CursorX, Y:= CursorY}

        return CurrentPos
 
    GetYawDelta(Current: rotation, Last: rotation): float =
        CurrentYaw:= GetYawFromRotation(Current)
        LastYaw:= GetYawFromRotation(Last)
 
        Delta:= CurrentYaw - LastYaw
        if. Delta > 180.0 then Delta - 360.0 else:
            if. Delta < -180.0 then Delta + 360.0 else Delta
 
    GetYawFromRotation(Rot: rotation): float =
        YPR:= Rot.GetYawPitchRollDegrees()
        if. Yaw:= YPR[0] then return Yaw else return 0.0
 
    GetPitchFromRotation(Rot: rotation): float =
        YPR:= Rot.GetYawPitchRollDegrees()
        if. Pitch:= YPR[1] then return Pitch else return 0.0