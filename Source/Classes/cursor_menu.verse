using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

# Primary parent class for cursor based menus
cursor_menu := class<abstract>(ui):

    LeftClickInput : input_trigger_device
    Cursor : cursor = cursor{Layer := 999 ,Size:=vector2{X:=50.0,Y:=70.0}}

    var UIElements : []ui_element = array{}

    RemoveUIEvent : event(player)

    BuildCanvas():canvas

    # Setup canvas, add all custom elements, add the cursor, start watching for clicks.
    Init(Player : player):void=
        set Canvas = BuildCanvas()
        for:
            UIElement : UIElements
        do:
            Canvas.AddWidget(
                UIElement.GetCanvasSlot()
            )

        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Player.ClickHandler()}

    # Move the cursor and check for any hover collisions
    MoveCursor(NewPosition : vector2):void=
        Cursor.SetPosition(NewPosition)
        HoverCheck(NewPosition)

    # Basic brute force cursor collision check, returns the last element hovered if there is one.
    HoverCheck(CursorPosition : vector2):?ui_element=
        var HoveredElement : ?ui_element = false
        for:
            Element : UIElements
        do:
            if:
                Element.IsHovering[CursorPosition]
            then:
                set HoveredElement = option{Element}
                if:
                    not Element.Hovered?
                then:
                    Element.OnHoverEnter()
            else:
                if:
                    Element.Hovered?
                then:
                    Element.OnHoverExit()
        if:
            HoveredElement?
        then:
            Cursor.OnHoverEnter()
        else:
            Cursor.OnHoverExit()

        return HoveredElement

    (Player : player).Drag(Element : ui_element, Offset : vector2)<suspends>:void=
        race:
            AwaitRemoval(Player)
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

    (Player : player).ClickHandler()<suspends>:void=
        race:
            AwaitRemoval(Player)
            loop:
                Clicker := LeftClickInput.PressedEvent.Await()
                if:
                    Clicker = Player
                then:
                    CursorPosition := Cursor.GetPosition()
                    HoveredElement := HoverCheck(CursorPosition)
                    if:
                        Element := HoveredElement?
                    then:
                        if:
                            Element.Draggable?
                        then:
                            Offset := CursorPosition - Element.GetPosition()
                            spawn{Player.Drag(Element, Offset)}
                        Element.OnClick()
                        spawn{Player.ReleaseHandler(Element)}

    (Player : player).ReleaseHandler(Element : ui_element)<suspends>:void=
        race:
            AwaitRemoval(Player)
            loop:
                ReleaseResult := LeftClickInput.ReleasedEvent.Await()
                if:
                    ReleaseResult(0) = Player
                then:
                    Element.OnRelease()
                    break

    # Kills any loops running when player leaves / is signaled to remove their UI via the removal event
    AwaitRemoval(Player : player)<suspends>:void=
        race:
            loop:
                PlayerRemoved := RemoveUIEvent.Await()
                if:
                    PlayerRemoved = Player
                then:
                    break
            loop:
                PlayerRemoved := LeftClickInput.GetPlayspace().PlayerRemovedEvent().Await()
                if:
                    PlayerRemoved = Player
                then:
                    break

