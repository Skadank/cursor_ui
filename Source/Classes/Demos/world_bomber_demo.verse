using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

world_bomber_menu := class(cursor_menu):

    Explosive : explosive_device

    MoveCursor<override>(NewPosition : vector2):void=
        Cursor.SetPosition(NewPosition)

    (Player : player).ClickHandler<override>()<suspends>:void=
        race:
            AwaitRemoval(Player)
            loop:
                Clicker := LeftClickInput.PressedEvent.Await()
                Explosive.Reset()
                if:
                    Clicker = Player
                then:
                    CursorPosition := Cursor.GetPosition()
                    WorldPosition := vector3{X:=CursorPosition.X, Y:=1080.0 - CursorPosition.Y,Z:=0.0}
                    if:
                        Explosive.TeleportTo[WorldPosition,IdentityRotation()]
                    Sleep(0.1)
                    Explosive.Explode(Player)

    Init<override>(Player : player):void=
        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )
        spawn{Player.ClickHandler()}

    BuildCanvas<override>():canvas=canvas{}
    