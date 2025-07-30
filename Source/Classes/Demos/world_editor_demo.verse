using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

world_object := class<concrete>(ui_element):

    Layer<override> : int = 25

    @editable
    Size<override> : vector2 = vector2{X:=200.0,Y:=200.0}

    @editable
    Prop : creative_prop = creative_prop{}

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

world_editor_menu := class(cursor_menu):

    MainOverlay : overlay = overlay{}

    (Player : player).Drag<override>(Element : ui_element, Offset : vector2)<suspends>:void=
        if:
            WorldObject := world_object[Element]
        then:
            race:
                AwaitRemoval(Player)
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

    Init<override>(Player : player):void=
        for:
            UIElement : UIElements
            WorldObject := world_object[UIElement]
        do:
            WorldPosition := WorldObject.Prop.GetTransform().Translation
            ScreenPosition := vector2{X:=WorldPosition.X, Y := 1080.0 - WorldPosition.Y}
            WorldObject.SetPosition(ScreenPosition)
            Canvas.AddWidget(
                WorldObject.GetCanvasSlot()
            )

        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Player.ClickHandler()}

    BuildCanvas<override>():canvas=canvas{}
    