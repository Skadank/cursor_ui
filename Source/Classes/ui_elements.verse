using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }


positional := interface:
    var Position : vector2 = vector2{X:=1920.0/2.0, Y:=1080.0/2.0}

    SetPosition(NewPosition : vector2):void

    GetPosition():vector2

sizeable := interface:
    Size : vector2

hoverable := interface:

    var Hovered : logic = false

    # Checks whether a point lies within this UI element
    # Mainly used for checking if cursor is hovering something, but has great applications elsewhere, as seen
    # in the minecraft crafting table menu demo, and merge game(s) demo(s). 
    # Parameter:
    #   - vector2 : The position to consider for the hover / overlap check.
    IsHovering(:vector2)<decides><transacts>:void

    OnHoverEnter():void

    OnHoverExit():void

    GetHoverAnimationState():float

    SetHoverAnimationState(State : float):void

clickable := interface:

    OnClick():void

    OnRelease():void

# This isn't all that useful in most cases and probably doesn't need to be inherited by the ui_element class, maybe get rid of it later.
colorable := interface:
    DefaultColor: color = NamedColors.White
    HoverColor : color = NamedColors.White

# An abstract parent class for creating various interactive UI elements
ui_element := class<abstract><unique>(positional, sizeable, hoverable, colorable, clickable):

    Draggable : logic = true
    # The Z index the element will appear on, lower valued elements will appear underneath higher valued elements
    Layer : int
    
    PaddingX : color_block = color_block{DefaultDesiredSize:=vector2{X:=1920.0/2.0, Y:=1.0},DefaultOpacity:=0.0}
    PaddingY : color_block = color_block{DefaultDesiredSize:=vector2{X:=1.0, Y:=1080.0/2.0},DefaultOpacity:=0.0}
    var MainStackBox : stack_box = stack_box{Orientation:=orientation.Horizontal}

    GetCanvasSlot():canvas_slot

    GetPosition<override>():vector2=Position

    # Set the position of the UI element on the screen.
    # Currently, elements are positioned relative to a (0.5,0.5) anchor position could expand this later 
    # to have more freedom, as with the Horizontal and Vertical alignment fields used within regular verse UI widgets. 
    SetPosition<override>(NewPosition : vector2):void=
        set Position = NewPosition
        PaddingX.SetDesiredSize(vector2{X:=NewPosition.X - (Size.X / 2.0), Y:=1.0})
        PaddingY.SetDesiredSize(vector2{X:=1.0, Y:=NewPosition.Y - (Size.Y / 2.0)})
    
    # Sets up the canvas slot in the context of a moveable widget on the screen.
    # Elements are placed within two stack_boxes each with a padding block that will affect the desired
    # UI elements horizontal and vertical position, with the PaddingX block being the offset, in pixels
    # from the left side of the screen, and the PaddingY block being the offset, in pixels from the bottom
    # of the screen, that is to say, all elements are positioned on the screen with 0,0 (0px,0px) being the bottom left
    # corner, and 1,1 (1920px,1080px) being the top right corner. 
    # With this approach, the padding blocks can be resized to dynamically move elements around the screen with ease.
    # Parameters:
    #   - Widget: The element to add to the canvas
    # 
    # Returns:
    #   - Tuple(canvas_slot, stack_box):
    #       - canvas_slot: The canvas slot being created, to be added to the canvas
    #       - stack_box: The container that the element, and the padding blocks are placed within
    #       - mainly useful for removing elements and their padding/stackbox overhead from the screen 
    BuildCanvasSlot(Widget : widget):tuple(canvas_slot,stack_box)=
        StackBox := stack_box:
            Orientation:=orientation.Horizontal
            Slots:=array:
                stack_box_slot:
                    HorizontalAlignment:=HLeft
                    VerticalAlignment:=VBottom
                    Widget:=PaddingX
                stack_box_slot:
                    HorizontalAlignment:=HLeft
                    VerticalAlignment:=VBottom
                    Widget:=stack_box:
                        Orientation:=orientation.Vertical
                        Slots:=array:
                            stack_box_slot:
                                HorizontalAlignment:=HLeft
                                VerticalAlignment:=VBottom
                                Widget:=Widget
                            stack_box_slot:
                                HorizontalAlignment:=HLeft
                                VerticalAlignment:=VBottom
                                Widget:=PaddingY
        CanvasSlot := canvas_slot:
            Offsets:=margin{Bottom:=1080.0,Right:=1920.0}
            Anchors:=AnchorsBottomLeft()
            Alignment:=vector2{X:=0.0,Y:=1.0}
            # SizeToContent:=true
            ZOrder:=if(Z := type{_X:int where 0 <= _X, _X <= 2147483647}[Layer]) then Z else 50
            Widget:=StackBox
        return (CanvasSlot,StackBox)

    # Animate a hover state from 0.0 -> 1.0 over 0.2 seconds (arbitrary length but good for quick hover type anims)
    # Params:
    #   - Hovering : A boolean indication if the animation should play forward (on hover enter), or backwards (on hover leave) 
    NormalizedHoverAnimation(Hovering : logic)<suspends>:void=
        Fps := 30.0
        Duration := 0.2
        Frames := Fps * Duration
        Delta := 1.0 / Frames
        FrameDuration := 1.0 / Fps
        var Progress : float = if(Hovering?) then 0.0 else 1.0
        loop:
            if:
                Hovering?
            then:    
                set Progress += Delta
            else:
                set Progress -= Delta

            SetHoverAnimationState(Progress)
            Sleep(FrameDuration)
            CurrentState := GetHoverAnimationState()
            if:
                (Hovering? and CurrentState >= 1.0) or (not Hovering? and CurrentState <= 0.0)
            then:
                SetHoverAnimationState(if(Hovering?) then 1.0 else 0.0)
                break
                
# A simple colored shape abstract parent class
# Mainly used for demo / testing, though it probably has some use cases somewhere
colored_shape := class<abstract>(ui_element):

    var Shape : texture_block = texture_block{DefaultImage:=Textures.Circle}

    GetCanvasSlot<override>():canvas_slot=
        SetPosition(Position)
        Result := BuildCanvasSlot(Shape)
        set MainStackBox = Result(1)
        Result(0)

    OnClick<override>():void=
        block:

    OnRelease<override>():void=
        block:

    OnHoverEnter<override>():void=
        set Hovered = true
        Shape.SetTint(HoverColor)

    OnHoverExit<override>():void=
        set Hovered = false
        Shape.SetTint(DefaultColor)

    GetHoverAnimationState<override>():float={0.0}

    SetHoverAnimationState<override>(State : float):void={}

circle := class(colored_shape):

    block:
        set Shape = texture_block:
            DefaultDesiredSize:=Size
            DefaultImage:=Textures.Circle
            DefaultTint:=DefaultColor

    var Shape<override> : texture_block = texture_block{DefaultImage:=Textures.Circle}

    IsHovering<override>(CursorPosition : vector2)<decides><transacts>:void=
        Self.CircleOverlapCheck[CursorPosition]

square := class(colored_shape):

    var Shape<override> : texture_block = texture_block{DefaultImage:=Textures.Square}

    block:
        set Shape = texture_block:
            DefaultDesiredSize:=Size
            DefaultImage:=Textures.Square
            DefaultTint:=DefaultColor

    IsHovering<override>(CursorPosition : vector2)<decides><transacts>:void=
        Self.SquareOverlapCheck[CursorPosition]

material_button := class<abstract>(ui_element):

    var ButtonMaterialBlock : material_block = material_block{DefaultImage := Materials.MM_Scale_Button_material{}}

    GetCanvasSlot<override>():canvas_slot=
        SetPosition(Position)
        Result := Self.BuildCanvasSlot(ButtonMaterialBlock)
        set MainStackBox = Result(1)
        Result(0)

    OnHoverEnter<override>():void=
        set Hovered = true
        spawn{HoverAnimation()}

    OnHoverExit<override>():void=
        set Hovered = false
        spawn{UnHoverAnimation()}

    IsHovering<override>(CursorPosition : vector2)<decides><transacts>:void=
        Self.SquareOverlapCheck[CursorPosition]

    HoverAnimation()<suspends>:void=
        NormalizedHoverAnimation(true)

    UnHoverAnimation()<suspends>:void=
        NormalizedHoverAnimation(false)

hover_scale_button := class(material_button):

    var ButtonMaterial : Materials.MM_Scale_Button_material = Materials.MM_Scale_Button_material{}

    block:
        set ButtonMaterial = Materials.MM_Scale_Button_material{Scale:=0.0}
        set ButtonMaterialBlock = material_block{DefaultImage:=ButtonMaterial, DefaultDesiredSize:=Size}

    OnClick<override>():void=
        block:

    OnRelease<override>():void=
        block:

    GetHoverAnimationState<override>():float=
        ButtonMaterial.Scale

    SetHoverAnimationState<override>(State : float):void=
        set ButtonMaterial.Scale = State

hover_shine_button := class(material_button):

    var ButtonMaterial : Materials.MM_Shine_Button_material = Materials.MM_Shine_Button_material{}

    block:
        set ButtonMaterial = Materials.MM_Shine_Button_material{Shine:=0.0}
        set ButtonMaterialBlock = material_block{DefaultImage:=ButtonMaterial, DefaultDesiredSize:=Size}

    OnClick<override>():void=
        block:

    OnRelease<override>():void=
        block:

    GetHoverAnimationState<override>():float=
        ButtonMaterial.Shine

    SetHoverAnimationState<override>(State : float):void=
        set ButtonMaterial.Shine = State

hover_wiggle_button := class(material_button):

    var ButtonMaterial : Materials.MM_Rotator_Button_material = Materials.MM_Rotator_Button_material{}

    block:
        set ButtonMaterial = Materials.MM_Rotator_Button_material{Clicked := 0.0,Wiggle:=0.0}
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

hover_fade_button := class(material_button):

    var ButtonMaterial : Materials.MM_Fade_Button_material = Materials.MM_Fade_Button_material{}

    block:
        set ButtonMaterial = Materials.MM_Fade_Button_material{Clicked := 0.0,Fade := 0.0}
        set ButtonMaterialBlock = material_block{DefaultImage:=ButtonMaterial, DefaultDesiredSize:=Size}

    OnClick<override>():void=
        set ButtonMaterial.Clicked = 1.0

    OnRelease<override>():void=
        set ButtonMaterial.Clicked = 0.0

    GetHoverAnimationState<override>():float=
        ButtonMaterial.Fade

    SetHoverAnimationState<override>(State : float):void=
        set ButtonMaterial.Fade = State

texture_element := class(ui_element):

    Texture : texture
    var TextureBlock : texture_block = texture_block{DefaultImage:=Textures.Circle}

    block:
        set TextureBlock = texture_block:
            DefaultImage:=Texture
            DefaultDesiredSize:=Size

    GetCanvasSlot<override>():canvas_slot=
        SetPosition(Position)
        Result := BuildCanvasSlot(TextureBlock)
        set MainStackBox = Result(1)
        Result(0)

    OnClick<override>():void=
        block:

    OnRelease<override>():void=
        block:

    OnHoverEnter<override>():void=
        set Hovered = true
        TextureBlock.SetTint(HoverColor)

    OnHoverExit<override>():void=
        set Hovered = false
        TextureBlock.SetTint(DefaultColor)

    IsHovering<override>(ElementPosition : vector2)<decides><transacts>:void=
        Self.SquareOverlapCheck[ElementPosition]

    GetHoverAnimationState<override>():float={0.0}

    SetHoverAnimationState<override>(State : float):void={}

# A simple cursor element used throughout the demos
cursor := class(ui_element):
   
    CursorTexture : texture = Textures.CursorIcon
    CursorHoverTexture : texture = Textures.CursorHoverIcon
    var CursorTextureBlock : texture_block = texture_block{DefaultImage :=Textures.CursorIcon}

    block:
        set CursorTextureBlock = texture_block{DefaultImage :=CursorTexture,DefaultDesiredSize:=Size}

    GetCanvasSlot<override>():canvas_slot=
        SetPosition(Position)
        Result := Self.BuildCanvasSlot(CursorTextureBlock)
        set MainStackBox = Result(1)
        Result(0)

    OnClick<override>():void={}

    OnRelease<override>():void={}

    IsHovering<override>(CursorPosition : vector2)<decides><transacts>:void=
        Distance(CursorPosition, Position) <= Size.X / 2.0  

    OnHoverEnter<override>():void=
        CursorTextureBlock.SetImage(CursorHoverTexture)

    OnHoverExit<override>():void=
        CursorTextureBlock.SetImage(CursorTexture)

    GetHoverAnimationState<override>():float=0.0

    SetHoverAnimationState<override>(State : float):void={}
