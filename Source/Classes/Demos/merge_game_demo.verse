using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

MergeTextures : []texture = array{
    Textures.MakeShiftAR
    Textures.BasicAR
    Textures.ScarAR
    Textures.ExcaliberAR
    Textures.Crown
}

merge_element := class(material_button):

    Texture : texture
    Index : int
    HoverColor<override> : color = NamedColors.LightGrey
    
    var ButtonMaterial : Materials.MM_Rotator_Texture_material = Materials.MM_Rotator_Texture_material{}

    block:
        set ButtonMaterial = Materials.MM_Rotator_Texture_material{Texture:=Texture, Clicked := 0.0,Wiggle:=0.0}
        set ButtonMaterialBlock = material_block{DefaultImage:=ButtonMaterial, DefaultDesiredSize:=Size}

    OnClick<override>():void=
        set ButtonMaterial.Clicked = 1.0

    OnRelease<override>():void=
        set ButtonMaterial.Clicked = 0.0

    HoverAnimation<override>()<suspends>:void=
        set ButtonMaterial.Wiggle = 1.0

    UnHoverAnimation<override>()<suspends>:void=
        set ButtonMaterial.Wiggle = 0.0

    GetHoverAnimationState<override>():float=0.0

    SetHoverAnimationState<override>(State : float):void={}

merge_menu := class(cursor_menu):

    MergeSound : audio_player_device

    MainOverlay : overlay = overlay{}

    MergeSize : vector2 = vector2{X:=200.0,Y:=200.0}

    SpawnNewMergeable():void=
        RandomX := GetRandomFloat(100.0,1820.0)
        RandomY := GetRandomFloat(100.0,930.0)
        NewMergeElement := merge_element{Index:=0, Layer:=1,Size:=MergeSize,Position:=vector2{X:=RandomX,Y:=RandomY},Texture:=if(Texture :=  MergeTextures[0]) then Texture else Textures.MakeShiftAR}
        Canvas.AddWidget(
            NewMergeElement.GetCanvasSlot()
        )
        set UIElements += array{NewMergeElement}

    CheckMerges(Player : player):void=
        var PairsToBeMerged : [merge_element]merge_element = map{}
        var MarkedElements : [int]logic = map{}
        for:
            I := 0..UIElements.Length
            A := merge_element[UIElements[I]]
        do:
            for:
                J := 0..UIElements.Length
                not MarkedElements[J]
                not MarkedElements[I]
                I <> J
                B := merge_element[UIElements[J]]
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

    Merge(ElementA : merge_element, ElementB : merge_element):void=
        MidPoint := (ElementA.GetPosition() + ElementB.GetPosition()) / 2.0
        Canvas.RemoveWidget(ElementA.MainStackBox)
        Canvas.RemoveWidget(ElementB.MainStackBox)
        NewMergeIndex := ElementA.Index + 1
        if:
            MergedTexture := MergeTextures[NewMergeIndex]
        then:
            MergedElement := merge_element{Index:=NewMergeIndex,Texture:=MergedTexture, Layer := NewMergeIndex + 1, Size := MergeSize,Position:=MidPoint}
            Canvas.AddWidget(
                MergedElement.GetCanvasSlot()
            )
            set UIElements += array{MergedElement}
            
        set UIElements = UIElements.RemoveAllElements(ElementA)
        set UIElements = UIElements.RemoveAllElements(ElementB)

    (Player : player).Drag<override>(Element : ui_element, Offset : vector2)<suspends>:void=
        race:
            loop:
                ReleaseResult := LeftClickInput.ReleasedEvent.Await()
                if:
                    ReleaseResult(0) = Player
                then:
                    break
            loop:
                Sleep(0.0)
                CursorPosition := Cursor.GetPosition()
                Element.SetPosition(CursorPosition - Offset)

        CheckMerges(Player)

    Init<override>(Player : player):void=
        set Canvas = BuildCanvas()
        
        for:
            I := 0..16
        do:
            SpawnNewMergeable()

        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Player.ClickHandler()}

    BuildCanvas<override>():canvas=
        canvas:
            Slots:=array:
                canvas_slot:
                    Anchors:=AnchorsCenter()
                    Alignment:=vector2{X:=0.5,Y:=0.5}
                    SizeToContent:=true
                    Widget:=overlay:
                        Slots:=array:
                            overlay_slot:
                                Widget:=texture_block:
                                    DefaultImage:=Textures.Background
                                    DefaultDesiredSize:=vector2{X:=1920.0,Y:=1080.0}