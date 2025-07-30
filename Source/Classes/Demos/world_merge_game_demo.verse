using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }


world_merge_element := class(ui_element):

    Layer<override> : int = 25

    Index : int = 0

    Size<override> : vector2 = vector2{X:=250.0,Y:=250.0}

    var PropAsset : creative_prop_asset

    var Prop : creative_prop = creative_prop{}

    var Shape : color_block = color_block{DefaultOpacity:=0.0}

    GetCanvasSlot<override>():canvas_slot=
        SetPosition(Position)
        Result := Self.BuildCanvasSlot(Shape)
        set MainStackBox = Result(1)
        Result(0)

    IsHovering<override>(ElementPosition : vector2)<decides><transacts>:void=
        CircleOverlapCheck[ElementPosition]

    OnClick<override>():void={}

    OnRelease<override>():void={}

    OnHoverEnter<override>():void={}

    OnHoverExit<override>():void={}

    GetHoverAnimationState<override>():float={0.0}

    SetHoverAnimationState<override>(State : float):void={}

world_merge_menu := class(cursor_menu):

    MergeSound : audio_player_device

    PropAssets : []creative_prop_asset

    MergeSize : vector2 = vector2{X:=200.0,Y:=200.0}

    SpawnNewMergeable():void=
        RandomX := GetRandomFloat(100.0,1820.0)
        RandomY := GetRandomFloat(100.0,930.0)
        MergedElement := world_merge_element{Index:=0,PropAsset := if(Prop := PropAssets[0]) then Prop else DefaultCreativePropAsset, Layer:=1,Size:=MergeSize,Position:=vector2{X:=RandomX,Y:=RandomY}}
        Canvas.AddWidget(
            MergedElement.GetCanvasSlot()
        )
        WorldPosition := vector3{X:=RandomX, Y:=1080.0 - RandomY,Z:=0.0}

        if:
            Prop := SpawnProp(MergedElement.PropAsset,WorldPosition, IdentityRotation())(0)?
        then:
            set MergedElement.Prop = Prop

        set UIElements += array{MergedElement}

    CheckMerges(Player : player):void=
        var PairsToBeMerged : [world_merge_element]world_merge_element = map{}
        var MarkedElements : [int]logic = map{}
        for:
            I := 0..UIElements.Length
            A := world_merge_element[UIElements[I]]
        do:
            for:
                J := 0..UIElements.Length
                not MarkedElements[J]
                not MarkedElements[I]
                I <> J
                B := world_merge_element[UIElements[J]]
                A.IsHovering[B.Position]
            do:
                if:
                    set PairsToBeMerged[A] = B
                    set MarkedElements[J] = true
                    set MarkedElements[I] = true
                    
        for:
            A -> B : PairsToBeMerged
        do:
            MergeSound.Play(Player)
            Merge(A,B)

    Merge(ElementA : world_merge_element, ElementB : world_merge_element):void=
        MidPoint := (ElementA.GetPosition() + ElementB.GetPosition()) / 2.0
        Canvas.RemoveWidget(ElementA.MainStackBox)
        Canvas.RemoveWidget(ElementB.MainStackBox)
        NewMergeIndex := ElementA.Index + 1
        if:
            MergedTexture := MergeTextures[NewMergeIndex]
        then:
            MergedElement := world_merge_element{Index:=NewMergeIndex,PropAsset := if(Prop := PropAssets[NewMergeIndex]) then Prop else DefaultCreativePropAsset, Layer := NewMergeIndex + 1, Size := MergeSize,Position:=MidPoint}
            Canvas.AddWidget(
                MergedElement.GetCanvasSlot()
            )
            set UIElements += array{MergedElement}

            WorldPosition := vector3{X:=MidPoint.X, Y:=1080.0 - MidPoint.Y,Z:=0.0}
            
            if:
                Prop := SpawnProp(MergedElement.PropAsset,WorldPosition, IdentityRotation())(0)?
            then:
                set MergedElement.Prop = Prop

        ElementA.Prop.Dispose()
        ElementB.Prop.Dispose()

        set UIElements = UIElements.RemoveAllElements(ElementA)
        set UIElements = UIElements.RemoveAllElements(ElementB)

    (Player : player).Drag<override>(Element : ui_element, Offset : vector2)<suspends>:void=
        if:
            WorldObject := world_merge_element[Element]
        then:
            race:
                loop:
                    ReleaseResult := LeftClickInput.ReleasedEvent.Await()
                    if:
                        ReleaseResult(0) = Player
                    then:
                        break
                loop:
                    CursorPosition := Cursor.GetPosition()
                    WorldObject.SetPosition(CursorPosition - Offset)
                    WorldPosition := vector3{X:=CursorPosition.X, Y:=1080.0 - CursorPosition.Y,Z:=0.0}
                    WorldObject.Prop.MoveTo(WorldPosition,IdentityRotation(),0.03)
        CheckMerges(Player)

    Init<override>(Player : player):void=
        for:
            I := 0..15
        do:
            SpawnNewMergeable()

        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Player.ClickHandler()}

    BuildCanvas<override>():canvas=canvas{}