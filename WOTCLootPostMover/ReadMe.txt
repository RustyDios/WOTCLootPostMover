The aim of this mod is to split the loot drop posts from the center of the drop zone to the fore and aft edges, 
so that should you get a Psi/Focus Loot in the same spot as a Vulture/Timed Loot, both are easily visable.

	// includes ini settings copied from configureable loot timers
	// https://steamcommunity.com/sharedfiles/filedetails/?id=1124469629 Configureable Loot Timers

	Should work with;
	https://steamcommunity.com/sharedfiles/filedetails/?id=1440233515 WOTC Instant Loot (as that changes the actor, but not the meshname/XCGS)
	https://steamcommunity.com/sharedfiles/filedetails/?id=1128231549 Loot Pinatas (modifies LootTableManager)
	https://steamcommunity.com/sharedfiles/filedetails/?id=1343283560 Loot Pinatas LITE (modifies LootTableManager)
	https://steamcommunity.com/sharedfiles/filedetails/?id=1142377029 Grimy's Loot (Adds to the loot tables)
	https://steamcommunity.com/sharedfiles/filedetails/?id=1215333362 Reuseable Hunter Axe (Creates it's own Loot Drop, with a post in the center)

	+ModClassOverrides=(BaseGameClass="XComGameState_LootDrop", ModClass="XComGameState_LootDropSplitter")
	function EventListenerReturn OnLootDropCreated

	Should be safe to ADD mid-campaign in a strategy save, not during mid-tactical .. but a new campaign is recommended.
	Due to the Mod Class Override it might break ongoing campaigns if REMOVED after saving

	Many thanks to Robojumper, Musashi and Iridar for code help .. Kexx and Obelix for model/mesh help

======================================================================
Steam Desc	https://steamcommunity.com/sharedfiles/filedetails/?id=2043070900
======================================================================
[h1] Why the mod?[/h1]
The aim of this mod is to split the loot drop posts from the center of the drop zone to the fore and aft edges, 
so that should you get a Psi/Focus Loot in the same spot as a Vulture/Timed Loot, both are easily visable.

I made this mod primarily for myself as I got fed up missing out on loot because it was 'hidden' within a Psi Drop that I didn't care to pick up.

[h1] Config [/h1]
Includes ini settings copied and adapted from the configureable loot timers mod, with the difference that you can also set normal loot and psi loot timers at different values.
The defaults are set to the same as the base game at 3 rounds.

https://steamcommunity.com/sharedfiles/filedetails/?id=1124469629 Configureable Loot Timers

[h1] Compatibility and Issues [/h1]
Should work with all the following mods;

https://steamcommunity.com/sharedfiles/filedetails/?id=1440233515 WOTC Instant Loot (changes the actor, but not the meshname/XCGS)
https://steamcommunity.com/sharedfiles/filedetails/?id=1128231549 Loot Pinatas (modifies LootTableManager)
https://steamcommunity.com/sharedfiles/filedetails/?id=1343283560 Loot Pinatas LITE (modifies LootTableManager)
https://steamcommunity.com/sharedfiles/filedetails/?id=1142377029 Grimy's Loot (Adds to the loot tables)
https://steamcommunity.com/sharedfiles/filedetails/?id=1215333362 Reuseable Hunter Axe (Creates it's own Loot Drop)

[b]The mod overrides XComGameState_LootDrop[/b] and will likely conflict with any other mods that do the same. I had no issues using it with all the above mods though.
Should be safe to ADD mid-campaign in a strategy save, not during mid-tactical .. but a new campaign is recommended.
Due to the Mod Class Override it might break ongoing campaigns if REMOVED after saving

[h1] Credits and Thanks [/h1]
Many thanks to RoboJumper, Musashi and Iridar for code help .. Kexx and ObelixDK for model/mesh help
and of course all the good people over at the XCOM2 Modders discord :)

~ Enjoy [b]!![/b] and please [url=https://www.buymeacoffee.com/RustyDios] buy me a Cuppa Tea[/url]