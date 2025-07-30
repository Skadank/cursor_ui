using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

target := class<unique>(circle):
    
    var Shape<override> : texture_block = texture_block{DefaultImage:=Textures.Target}

    block:
        set Shape = texture_block:
            DefaultDesiredSize:=Size
            DefaultImage:=Textures.Target

target_game_menu := class(cursor_menu):

    Player : player

    var Hits : int = 0
    var Misses : int = 0
    var Accuracy : int = 0

    TimerTextBlock : text_block = text_block{DefaultTextColor:=NamedColors.White}
    HitsTextBlock : text_block = text_block{DefaultTextColor:=NamedColors.LawnGreen}
    MissesTextBlock : text_block = text_block{DefaultTextColor:=NamedColors.OrangeRed}
    AccuracyTextBlock : text_block = text_block{DefaultTextColor:=NamedColors.Orange}

    Timer : timer_device

    HitSound : audio_player_device
    GameOverSound : audio_player_device

    MainOverlay : overlay = overlay{}

    MoveCursor<override>(NewPosition : vector2):void=
        Cursor.SetPosition(NewPosition)

    ClickCheck(CursorPosition : vector2):void=
        for:
            UIElement : UIElements
            Target := target[UIElement]
        do:
            if:
                Target.IsHovering[CursorPosition]
            then:
                HandleClick(Target)
                Hit()
                return
        Miss()
            
    Hit():void=
        HitSound.Play(Player)
        set Hits += 1
        HitsTextBlock.SetText(ToMessage("{Hits}"))
        UpdateAccuracy()

    Miss():void=
        set Misses += 1
        MissesTextBlock.SetText(ToMessage("{Misses}"))
        UpdateAccuracy()

    UpdateAccuracy():void=
        if:    
            Acc := Round[((Hits * 1.0) / ((Hits * 1.0) + (Misses * 1.0))) * 100.0]
        then:
            set Accuracy = Acc
            AccuracyTextBlock.SetText(ToMessage("{Accuracy}%"))

    SpawnNewTarget():void=
        RandomX := GetRandomFloat(100.0,1820.0)
        RandomY := GetRandomFloat(100.0,930.0)

        RandomSize := GetRandomFloat(50.0,250.0)
        NewTarget := target{Layer:=50,Position:=vector2{X:=RandomX,Y:=RandomY},Size:=vector2{X:=RandomSize,Y:=RandomSize}}
        Canvas.AddWidget(
            NewTarget.GetCanvasSlot()
        )

        set UIElements += array{NewTarget}

    HandleClick(Target : ui_element):void=
        Canvas.RemoveWidget(Target.MainStackBox)
        set UIElements = UIElements.RemoveAllElements(Target)
        SpawnNewTarget()

    (P : player).ClickHandler<override>()<suspends>:void=
        race:
            Timer.SuccessEvent.Await()
            loop:
                Clicker := LeftClickInput.PressedEvent.Await()
                if:

                    player[Clicker] = Player
                then:
                    Position := Cursor.GetPosition()
                    ClickCheck(Position)

    Init<override>(P : player):void=

        TimerTextBlock.SetText(ToMessage(SecondsToMinuteSeconds(Timer.GetActiveDuration())))

        HitsTextBlock.SetText(ToMessage("0"))
        MissesTextBlock.SetText(ToMessage("0"))
        AccuracyTextBlock.SetText(ToMessage("0%"))

        set Canvas = BuildCanvas()
                
        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )

        spawn{TimerWatch()}
        spawn{Player.ClickHandler()}

    TimerWatch()<suspends>:void=
        Timer.Reset()
        Sleep(3.0)
        SpawnNewTarget()
        SpawnNewTarget()
        SpawnNewTarget()
        Timer.Start()
        race:
            Timer.SuccessEvent.Await()
            loop:
                Time := SecondsToMinuteSeconds(Timer.GetActiveDuration())
                TimerTextBlock.SetText(ToMessage(Time))
                Sleep(1.0)

        for:
            UIElement : UIElements
        do:
            Canvas.RemoveWidget(UIElement.MainStackBox)

        GameOverSound.Play(Player)
        Sleep(5.0)
        Self.RemoveFromPlayer(Player)
        if:
            FC := Player.GetFortCharacter[]
        then:
            FC.ReleaseFromStasis()

    BuildCanvas<override>():canvas=
        MainOverlay.AddWidget(
            overlay_slot:
                Widget:=texture_block:
                    DefaultImage:=Textures.TargetShooterBackground
                    DefaultDesiredSize:=vector2{X:=1920.0,Y:=1080.0}
        )
        # Timer
        MainOverlay.AddWidget(
            overlay_slot:
                Padding:=margin{Top:=40.0}
                HorizontalAlignment:=HCenter
                VerticalAlignment:=VTop
                Widget:=stack_box:
                    Orientation:=orientation.Horizontal
                    Slots:=array:
                        stack_box_slot:
                            Widget:=texture_block:
                                DefaultImage:=Textures.HourGlassIcon
                                DefaultDesiredSize:=vector2{X:=50.0,Y:=50.0}
                        stack_box_slot:
                            Padding:=margin{Left:=5.0}
                            VerticalAlignment:=VCenter
                            Widget:=TimerTextBlock
        )
        # Hits
        MainOverlay.AddWidget(
            overlay_slot:
                Padding:=margin{Left:=1200.0,Top:=50.0}
                HorizontalAlignment:=HLeft
                VerticalAlignment:=VTop
                Widget:=stack_box:
                    Orientation:=orientation.Horizontal
                    Slots:=array:
                        stack_box_slot:
                            Widget:=text_block:
                                DefaultText:=ToMessage("Hits: ")
                                DefaultTextColor:=NamedColors.White
                        stack_box_slot:
                            Widget:=HitsTextBlock
        )
        # Misses
        MainOverlay.AddWidget(
            overlay_slot:
                Padding:=margin{Left:=1350.0,Top:=50.0}
                HorizontalAlignment:=HLeft
                VerticalAlignment:=VTop
                Widget:=stack_box:
                    Orientation:=orientation.Horizontal
                    Slots:=array:
                        stack_box_slot:
                            Widget:=text_block:
                                DefaultText:=ToMessage("Misses: ")
                                DefaultTextColor:=NamedColors.White
                        stack_box_slot:
                            Widget:=MissesTextBlock
        )
        # Accuracy
        MainOverlay.AddWidget(
            overlay_slot:
                Padding:=margin{Left:=1550.0,Top:=50.0}
                HorizontalAlignment:=HLeft
                VerticalAlignment:=VTop
                Widget:=stack_box:
                    Orientation:=orientation.Horizontal
                    Slots:=array:
                        stack_box_slot:
                            Widget:=text_block:
                                DefaultText:=ToMessage("Accuracy: ")
                                DefaultTextColor:=NamedColors.White
                        stack_box_slot:
                            Widget:=AccuracyTextBlock
        )
        canvas:
            Slots:=array:
                canvas_slot:
                    Anchors:=AnchorsCenter()
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:=true
                    Widget:=MainOverlay
                            