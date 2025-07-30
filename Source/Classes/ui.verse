using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using { /Fortnite.com/UI }

ui := class<abstract>:
    var Canvas : canvas = canvas{}

    HandleClose(Msg : widget_message):void=
        RemoveFromPlayer(Msg.Player)

    AddToPlayer(Player : player, ConsumesInput : logic):void=
        if:
            PlayerUI := GetPlayerUI[Player]
        then:
            if:
                ConsumesInput?
            then:
                PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode:=ui_input_mode.All})
            else:
                PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode:=ui_input_mode.None})

    RemoveFromPlayer(Player : player):void=
        if:
            PlayerUI := GetPlayerUI[Player]
        then:
            PlayerUI.RemoveWidget(Canvas)

        