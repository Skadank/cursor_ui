using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

cookie_outline_shape := class(colored_shape):

    var Clicked : logic = false
    var Shape<override> : texture_block = texture_block{DefaultImage:=Textures.Square}
    
    DefaultColor<override> : color = color{R:=0.260,G:=0.144,B:=0.006}
    ClickedColor : color = color{R:=0.135,G:=0.075,B:=0.003}

    block:
        set Shape = texture_block:
            DefaultTint:=DefaultColor
            DefaultImage:=Textures.Square
            DefaultDesiredSize:=Size

    OnClick<override>():void=
        if:
            not Clicked?
        then:
            set Clicked = true
            Shape.SetTint(ClickedColor)

    IsHovering<override>(Pos : vector2)<decides><transacts>:void=
        Self.SquareOverlapCheck[Pos]

    # Don't really want hover states here, makes it too easy
    OnHoverEnter<override>():void={}
    OnHoverExit<override>():void={}

needle_cursor := class(cursor):

    CursorTexture<override> : texture = Textures.Needle 
    CursorHoverTexture<override> : texture = Textures.Needle 
    
    block:
        set CursorTextureBlock = texture_block{DefaultImage :=CursorTexture,DefaultDesiredSize:=Size}

    # Want cursor to click at the end point not the center for this one, probably for the regular one too actually...
    SetPosition<override>(NewPosition : vector2):void=
        set Position = NewPosition
        PaddingX.SetDesiredSize(vector2{X:=NewPosition.X, Y:=1.0})
        PaddingY.SetDesiredSize(vector2{X:=1.0, Y:=NewPosition.Y})

squid_game_cookie_menu := class(cursor_menu):

    NumPoints : int = 100

    Radius : float = 300.0

    Cursor<override> : needle_cursor = needle_cursor{Layer:=999,Size:=vector2{X:=400.0,Y:=400.0}}

    Init<override>(Player : player):void=
        set Canvas = BuildCanvas()

        set UIElements = for:
            Position : GetCirclePositions()
        do:
            Square := cookie_outline_shape{Layer:=55,Size:=vector2{X:=40.0,Y:=40.0},Position:=Position}
            Canvas.AddWidget(
                Square.GetCanvasSlot()
            )
            Square

        Canvas.AddWidget(
            Cursor.GetCanvasSlot()
        )

        spawn{Player.ClickHandler()}

    (Player : player).ClickHandler<override>()<suspends>:void=
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
                        Element.OnClick()

    GetCirclePositions()<transacts>:[]vector2=
        StepSize := (2 * PiFloat) / (NumPoints * 1.0)
        for:
            I := 0..NumPoints - 1
        do:
            Angle := I * StepSize
            X := 960.0 + Radius * Cos(Angle)
            Y := 540.0 + Radius * Sin(Angle)
            vector2{X:=X,Y:=Y}

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
                            overlay_slot:
                                HorizontalAlignment:=HCenter
                                VerticalAlignment:=VCenter
                                Widget:=texture_block:
                                    DefaultImage:=Textures.Circle
                                    DefaultDesiredSize:=vector2{X:=1000.0,Y:=1000.0}
                                    DefaultTint:=color{R:=0.533,G:=0.296,B:=0.013}
                            
                