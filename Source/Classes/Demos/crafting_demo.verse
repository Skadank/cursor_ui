using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

InventoryItemTextures : []texture = array{
    Textures.StickIcon
    Textures.OakWoodIcon
    Textures.WoodenPickaxeIcon
}

recipe := class:
    
    # Just an array of indexes that forms the rows of a recipe as follows -> 
    # 0, 1, 2 
    # 3, 4, 5
    # 6, 7, 8
    ItemIndexes : []int
    ResultIndex : int

    IsValid(Recipe : []int):logic=
        var Valid : logic = false
        for:
            I := 0..8
            Recipe[I] <> ItemIndexes[I]
        do:
            return false
        return true

crafting_inventory_item := class(texture_element):

    ItemIndex : int
    HoverColor<override> : color = NamedColors.LightGrey

crafting_menu := class(cursor_menu):

    MainOverlay : overlay = overlay{}

    var CraftingSlots : []ui_element = array{
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=650.0,Y:=920.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=760.0,Y:=920.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=870.0,Y:=920.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=650.0,Y:=800.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=760.0,Y:=800.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=870.0,Y:=800.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=650.0,Y:=680.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=760.0,Y:=680.0}, Size:=vector2{X:=100.0,Y:=100.0}}
        square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=870.0,Y:=680.0}, Size:=vector2{X:=100.0,Y:=100.0}}
    }

    CraftingResultSlot : square = square{Layer:=50, DefaultColor:=NamedColors.Grey,HoverColor:=NamedColors.DarkGrey,Position:=vector2{X:=1225.0,Y:=800.0}, Size:=vector2{X:=100.0,Y:=100.0}}

    var CraftingResult : ?crafting_inventory_item = false

    var InventoryItems : []crafting_inventory_item = array{
        crafting_inventory_item{Position:=vector2{X:=520.0,Y:=480.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=630.0,Y:=480.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=740.0,Y:=480.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=850.0,Y:=480.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=960.0,Y:=480.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=1070.0,Y:=480.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=1180.0,Y:=480.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=1290.0,Y:=480.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=1400.0,Y:=480.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=520.0,Y:=370.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=630.0,Y:=370.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=740.0,Y:=370.0},Texture:=Textures.StickIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=0}
        crafting_inventory_item{Position:=vector2{X:=850.0,Y:=370.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=960.0,Y:=370.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
        crafting_inventory_item{Position:=vector2{X:=1070.0,Y:=370.0},Texture:=Textures.OakWoodIcon, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=1}
    }

    Recipes : []recipe = array{
        # Pickaxe recipe? do 1 as wood block, 0 as stick? lol 2 as pickaxe
        recipe{
            ItemIndexes := array{1,1,1,-1,0,-1,-1,0,-1}
            ResultIndex := 2
            }
        recipe{
            ItemIndexes := array{0,0,-1,0,0,-1,-1,-1,-1}
            ResultIndex := 1
        }
        recipe{
            ItemIndexes := array{-1,-1,1,-1,-1,1,-1,-1,-1}
            ResultIndex := 0
        }
    }

    # Needs optimized (if i care...)
    GetItemsInBench():[]?crafting_inventory_item=
        # This is SUPER expensive at high item counts
        # 9 x Num items at worst case 
        profile("GetItemsInBench"):
            var Items : []?crafting_inventory_item = array{false,false,false,false,false,false,false,false,false}
            var ItemsFound : [crafting_inventory_item]logic = map{}
            for:
                Index -> CraftingSlot : CraftingSlots
            do:
                for:
                    InventoryItem : InventoryItems
                    not ItemsFound[InventoryItem]
                    InventoryItem.IsHovering[CraftingSlot.Position]
                do:
                    if:
                        set Items[Index] = option{InventoryItem}
                        set ItemsFound[InventoryItem] = true
            return Items

    TryFindRecipe():?recipe=
        ItemsInBench := GetItemsInBench().ToRecipeFormat()
        for:
            Recipe : Recipes
        do:
            IsValidRecipe := Recipe.IsValid(ItemsInBench)
            if:
                IsValidRecipe?
            then:
                return option{Recipe}
        return false

    HoverCheck<override>(CursorPosition : vector2):?crafting_inventory_item=
        var HoveredElement : ?crafting_inventory_item = false
        for:
            Element : InventoryItems
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

    CheckForRecipe():void=
        Print("Checking for recipes.")
        MaybeRecipe := TryFindRecipe()
        if:
            Recipe := MaybeRecipe?
            Texture :=InventoryItemTextures[Recipe.ResultIndex]
        then:
            ResultItem := crafting_inventory_item{Texture:=Texture, Size:=vector2{X:=100.0,Y:=100.0}, Layer:=51,ItemIndex:=Recipe.ResultIndex}
            set CraftingResult = option{ResultItem}
            set InventoryItems += array{ResultItem}
            ResultItem.SetPosition(CraftingResultSlot.Position)
            Canvas.AddWidget(
                ResultItem.GetCanvasSlot()
            )
        else:
            if:
                Result := CraftingResult?
            then:
                Canvas.RemoveWidget(
                    Result.MainStackBox
                )

            set CraftingResult = false

    LockInRecipe():void=
        Print("Locking recipe in")
        MaybeBenchItems := GetItemsInBench()
        for:
            MaybeBenchItem : MaybeBenchItems
            BenchItem := MaybeBenchItem?
        do:
            Canvas.RemoveWidget(
                BenchItem.MainStackBox
            )
            set InventoryItems = InventoryItems.RemoveAllElements(BenchItem)

        set CraftingResult = false

    (MaybeBenchItems : []?crafting_inventory_item).ToRecipeFormat():[]int=
        var Recipe : []int = {-1,-1,-1,-1,-1,-1,-1,-1,-1}
        for:
            Index -> MaybeBenchItem : MaybeBenchItems
            BenchItem := MaybeBenchItem?
        do:
            if:
                set Recipe[Index] = BenchItem.ItemIndex
        return Recipe


    (Agent : agent).Drag<override>(Element : ui_element, Offset : vector2)<suspends>:void=
        race:
            loop:
                Releaser := LeftClickInput.ReleasedEvent.Await()
                if:
                    Releaser(0) = Agent
                then:
                    break
            loop:
                Sleep(0.0)
                CursorPosition := Cursor.GetPosition()
                Element.SetPosition(CursorPosition - Offset)

        CheckForRecipe()

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
                        if:
                            CraftingResult? = Element
                        then:
                            LockInRecipe() 
                        if:
                            Element.Draggable?
                        then:
                            Offset := CursorPosition - Element.GetPosition()
                            spawn{Player.Drag(Element, Offset)}
                        Element.OnClick()
                        spawn{Player.ReleaseHandler(Element)}

    Init<override>(Player : player):void=
        set Canvas = BuildCanvas()
        for:
            UIElement : InventoryItems
        do:
            Canvas.AddWidget(
                UIElement.GetCanvasSlot()
            )

        for:
            CraftingSlot : CraftingSlots
        do:
            Canvas.AddWidget(
                CraftingSlot.GetCanvasSlot()
            )

        Canvas.AddWidget(
            CraftingResultSlot.GetCanvasSlot()
        )

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
                            overlay_slot:
                                HorizontalAlignment:=HCenter
                                VerticalAlignment:=VCenter
                                Widget:=texture_block:
                                    DefaultImage:=Textures.CraftingMenuBackground
                                    DefaultDesiredSize:=vector2{X:=1080.0,Y:=1080.0}