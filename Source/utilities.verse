using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

callBack(t: type):=class:
    Arg: t
    Func: type{_(:agent, :t):void}
    Invoke(Agent : agent):void = Func(Agent, Arg)

widgetCallBack(t: type):=class:
    Arg: t
    Func: type{_(:widget_message, :t):void}
    Invoke(Msg : widget_message):void = Func(Msg, Arg)

ToMessage<localizes>(String : string) : message = "{String}"
PlayerToMessage<localizes>(Agent : agent): message = "{Agent}"

AnchorsFill():anchors=anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=1.0}} 
AnchorsCenter():anchors=anchors{Minimum:=vector2{X:=0.5,Y:=0.5},Maximum:=vector2{X:=0.5,Y:=0.5}} 
AnchorsTopCenter():anchors=anchors{Minimum:=vector2{X:=0.5,Y:=0.0},Maximum:=vector2{X:=0.5,Y:=0.0}} 
AnchorsBottomCenter():anchors=anchors{Minimum:=vector2{X:=0.5,Y:=1.0},Maximum:=vector2{X:=0.5,Y:=1.0}} 
AnchorsBottomLeft():anchors=anchors{Minimum:=vector2{X:=0.0,Y:=1.0},Maximum:=vector2{X:=0.0,Y:=1.0}} 
AnchorsTopRight():anchors=anchors{Minimum:=vector2{X:=1.0,Y:=0.0},Maximum:=vector2{X:=1.0,Y:=0.0}} 
AnchorsTopLeft():anchors=anchors{Minimum:=vector2{X:=0.0,Y:=0.0},Maximum:=vector2{X:=0.0,Y:=0.0}}
AnchorsBottomFill():anchors=anchors{Minimum:=vector2{X:=0.0,Y:=1.0},Maximum:=vector2{X:=1.0,Y:=1.0}}

TextBlock(Color : color, Text : message, Shadow : logic):text_block=
    text_block:
        DefaultTextColor:=Color
        DefaultText := Text
        DefaultShadowOffset:=if(Shadow?) then option{vector2{X:=2.0,Y:=2.0}} else false
        DefaultShadowColor:=NamedColors.Black
        DefaultShadowOpacity:=if(Shadow?) then 1.0 else 0.0

ColorBlock(Color : color, Opacity : type{_X:float where 0.000000 <= _X, _X <= 1.000000}, Size : vector2):color_block=
    color_block:
        DefaultColor:=Color
        DefaultOpacity:=Opacity
        DefaultDesiredSize:=Size

MakeUniformMargin(X : float):margin=
    margin{Top:=X,Right:=X,Bottom:=X,Left:=X}

HCenter : horizontal_alignment = horizontal_alignment.Center
HLeft : horizontal_alignment = horizontal_alignment.Left
HRight : horizontal_alignment = horizontal_alignment.Right
HFill : horizontal_alignment = horizontal_alignment.Fill

VCenter : vertical_alignment = vertical_alignment.Center
VTop : vertical_alignment = vertical_alignment.Top
VBottom : vertical_alignment = vertical_alignment.Bottom
VFill : vertical_alignment = vertical_alignment.Fill

SecondsToMinuteSeconds(Time : float):string=
    var TimeString : string = ""
    if:
        Minutes := Floor[Time / 60.0]
        Seconds := Mod[Floor[Time],Floor[60.0]]
    then:
        set TimeString = if(Seconds < 10) then "{Minutes}:0{Seconds}" else "{Minutes}:{Seconds}" 

    return TimeString

(Vector3 : vector3).ToVector2():vector2=
    vector2{X:=Vector3.Y, Y :=Vector3.Z}

Scalar : float = 1080.0/1920.0

# The vector2 incoming is normalized and made positive
(Vector2 : vector2).ToScreenCoordinate():vector2=
    ClampedX := Min(Max(Vector2.X, 0.0),1.0) 
    ClampedY := Min(Max(Vector2.Y, 0.0),Scalar) 
    vector2{X:=ClampedX * 1920.0, Y:=ClampedY * 1920.0}

(Vector3 : vector3).ToScreenCoordinate():vector2=
    ((Vector3.ToVector2() + vector2{X:=1.0,Y:=1.0}) / 2.0).ToScreenCoordinate()
                
(E : ui_element).SquareOverlapCheck(ElementPosition : vector2)<decides><transacts>:void=
    HalfWidth := E.Size.X / 2.0
    HalfHeight := E.Size.Y / 2.0
    MinX := E.Position.X - HalfWidth
    MaxX := E.Position.X + HalfWidth
    MinY := E.Position.Y - HalfHeight
    MaxY := E.Position.Y + HalfHeight

    ElementPosition.X >= MinX and ElementPosition.X <= MaxX
    ElementPosition.Y >= MinY and ElementPosition.Y <= MaxY

(E : ui_element).CircleOverlapCheck(ElementPosition : vector2)<decides><transacts>:void=
    Distance(ElementPosition, E.Position) <= E.Size.X / 2.0  

