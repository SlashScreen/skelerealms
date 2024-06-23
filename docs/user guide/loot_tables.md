# Loot Tables

Skelerealms comes with an in-house loot table system inspired by that seen in Minecraft. It's created using a tree of `SKLootTableItem`s underneath an associated `SKLootTable`. A "resolved" (rolled) loot table creates a result consisting of:

- Generated items
- Unique items
- Currencies 

Each of these can be manipulated by creating a nested of various `SKLootTableItem`s. Some loot table items will affect the chances or number of child items, while others will instead contribute items to the output. These can be combined in ways to create complex results. [Consider the following](https://www.youtube.com/watch?v=uI_N2tLw-vI) loot table:

- SKLootTable
    - SKLTItem (Contains sword)
    - SKLTXOfItem (Set to between 1 and 3)
        - SKLTCurrency (Set to between 5 and 20 gold coins)

This loot table will always return a sword, and then will generate 5 to 20 coins 1 to 3 times. Not the most practical example, but hopefully you get the idea.  

You can put entities you've created (Unique items) into a loot table with `SKLTItemEntity`. Do note, however, that no matter how many times a unique item is rolled, it will only appear in the result once. Non-item entities will appear in the result, but `InventoryComponent` will not add non-item entities into its inventory. Also, the unique items should still be saved and stored within Skelerealms' entities path, as configured in the project settings.  

Built-in, Loot tables are applicable to the following components:
- `InventoryComponent`, which will roll when the entity is `generate`d 
- `ChestComponent`, which will roll and fill an inventory whenever the chest refreshes
