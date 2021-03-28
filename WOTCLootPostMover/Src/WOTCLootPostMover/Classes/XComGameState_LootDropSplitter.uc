//---------------------------------------------------------------------------------------
//  FILE:   XCGS_LootDropSplitter
//  
//	File created by RustyDios	20/03/20	12:00	
//	LAST UPDATED				17/08/20	00:00
//
//	change to ELR to split loot into two different pools and display both
//
//---------------------------------------------------------------------------------------

class XComGameState_LootDropSplitter extends XComGameState_Lootdrop;

function EventListenerReturn OnLootDropCreated(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_LootDrop LootDropState;
	local StateObjectReference AbilityRef;
	local XComGameStateContext_Ability NewAbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit Iter;
	local XComWorldData WorldData;
	local vector SourcePos, TargetPos;
	local float LootCheckDistanceSq;
	local XComGameStateHistory History;

	local XComGameState			NewGameState;
	local XComGameState_Item	ItemState;
	local array<XComGameState_Item> Items, PsiItems;
	local int i;

	//create a gamestate detailing this change
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SplitPsiDrop");

	// search for nearby looters who should immediately loot
	WorldData = `XWORLD;
	History = `XCOMHISTORY;
	TargetPos = WorldData.GetPositionFromTileCoordinates(TileLocation);

	LootDropState = XComGameState_LootDrop(EventData);
	if( LootDropState.HasLoot() )
	{
		foreach History.IterateByClassType(class'XComGameState_Unit', Iter)
		{
			if( Iter.IsAbleToAct() )
			{
				AbilityRef.ObjectID = -1;
				AbilityRef = Iter.FindAbility('Loot');
				if( AbilityRef.ObjectID > 0 )
				{
					// check if a friendly unit is within loot range and able to act
					SourcePos = WorldData.GetPositionFromTileCoordinates(Iter.TileLocation);
					LootCheckDistanceSq = VSizeSq(TargetPos - SourcePos);
					if( LootCheckDistanceSq < Square(class'X2Ability_DefaultAbilitySet'.default.LOOT_RANGE) )
					{
						AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

						if( AbilityState != None )
						{
							NewAbilityContext = class'XComGameStateContext_Ability'.static.BuildContextFromAbility(AbilityState, LootDropState.ObjectID);
							if( NewAbilityContext.Validate() )
							{
								`XCOMGAME.GameRuleset.SubmitGameStateContext(NewAbilityContext);
							}
						}

						break;
					}
				}
			}
		}

		//====================================================================================
		//		START RUSTY CODE
		//====================================================================================

		//add checks to split psi loot from normal loot? ... if current state has both types
		//this should theorectically pull all the loot out into new drops
		if (LootDropState.HasPsiLoot() && LootDropState.HasNonPsiLoot() ) 
		{
			//search the loot drop for loot and remove and separate them
			for (i = 0; i <= LootDropState.LootableItemRefs.Length; ++i)
			{
				ItemState = XComGameState_Item(History.GetGameStateForObjectID(LootDropState.LootableItemRefs[i].ObjectID));
				if (ItemState != none && X2FocusLootItemTemplate(ItemState.GetMyTemplate()) != none)
				{
					// psi loot
					PsiItems.AddItem(ItemState);
					`log("Loot Drop Index ["@ i @ "] added to _psi_ drop" @ ItemState.GetMyTemplate().DataName ,class'X2DownloadableContentInfo_WOTCLootPostMover'.default.bEnableLogging,'WOTCLootPostMover');
				}
				else if (ItemState != none)
				{
					//non-psi loot
					Items.AddItem(ItemState);
					`log("Loot Drop Index ["@ i @ "] added to _new_ drop"@ ItemState.GetMyTemplate().DataName ,class'X2DownloadableContentInfo_WOTCLootPostMover'.default.bEnableLogging,'WOTCLootPostMover');
				}

				//remove the loot
				LootDropState.RemoveLoot(LootDropState.LootableItemRefs[i], NewGameState);
			}

			//create new loot drop for the splits, for both pools as we removed everything in this one
			//static function CreateLootDrop(XComGameState NewGameState, const out array<XComGameState_Item> LootItems, Lootable LootSource, bool bExpireLoot)
			//	if (!bExpireLoot)		++LootDrop.LootExpirationTurnsRemaining .... ie +1 turn .. used for loot dropped from a friendly source
			class'XComGameState_LootDrop'.static.CreateLootDrop(NewGameState, Items, self, true);
			class'XComGameState_LootDrop'.static.CreateLootDrop(NewGameState, PsiItems, self, true);

			LootDropState.LootableItemRefs.Length = 0;
			`log("Loot drop split",class'X2DownloadableContentInfo_WOTCLootPostMover'.default.bEnableLogging,'WOTCLootPostMover');

		}

		// start configureable loot timers
		// because this will get run for the new loot drops too :)
		if (class'X2DownloadableContentInfo_WOTCLootPostMover'.default.bLootExpirationEnabled)
		{
			LootDropState.LootExpirationTurnsRemaining = class'X2DownloadableContentInfo_WOTCLootPostMover'.default.iLootExpirationMaxTurns;

			//update psi loot timers seperately
			if (LootDropState.HasPsiLoot() )
			{
				LootDropState.LootExpirationTurnsRemaining = class'X2DownloadableContentInfo_WOTCLootPostMover'.default.iLootExpirationMaxTurns_Psi;
			}

		}
		else
		{
			// Set the max turns to a high value to visually remove the turn counter.
			// We also want to unregister the 'PlayerTurnBegun' event on the loot drop, this event is only used to decrement the expiration counter so this should remove loot expiration.
			LootDropState.LootExpirationTurnsRemaining = 999;
			`XEVENTMGR.UnRegisterFromEvent(LootDropState, 'PlayerTurnBegun');
		}

		//if this was somehow updated check if empty and remove AND ensure to submit the new gamestates
		LootDropState.CheckIfEmptyAndRemoveEvents();
		if (LootDropState.LootableItemRefs.Length <= 0)
		{
			// Use special visualization effect for this loot clear
			XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = BuildVisualizationForLootSplit;
		}

		SubmitNewGameState(NewGameState);
	}

	SubmitNewGameState(NewGameState);

		//====================================================================================
		//		END RUSTY CODE
		//====================================================================================

	return ELR_NoInterrupt;
}

//====================================================================================
//	HELPER Funcs - Submit GS copied from Musashi code
//====================================================================================

//helper function to submit new game states        
protected static function SubmitNewGameState(out XComGameState NewGameState)
{
    local X2TacticalGameRuleset		TacticalRules;
    local XComGameStateHistory		History;
 
    if (NewGameState.GetNumGameStateObjects() > 0)
    {
        TacticalRules = `TACTICALRULES;
        TacticalRules.SubmitGameState(NewGameState);
    }
    else
    {
        History = `XCOMHISTORY;
        History.CleanupPendingGameState(NewGameState);
    }
}

//a copy of XComGameState_LootDrop BuildVisualizationForLootExpired stripping all the stuff that tells the player the drop is 'gone'
function BuildVisualizationForLootSplit(XComGameState VisualizeGameState)
{
	local XComGameStateHistory			History;
	local XComGameState_LootDrop		LootDropState;
	local XComGameStateContext			VisualizeStateContext;

	local VisualizationActionMetadata	ActionMetadata;

	local X2Action_LootDropMarker		LootDropMarker;
	local X2Action_PlayEffect			LootExpiredEffectAction;
	local X2Action_StartStopSound		SoundAction;

	local XComContentManager			ContentManager;

	local XComWorldData					World;
	local TTile							EffectLocationTile;

	History = `XCOMHISTORY;
	World = `XWORLD;
	ContentManager = `CONTENT;
	VisualizeStateContext = VisualizeGameState.GetContext();

	// Add a Track for the loot drop
	History.GetCurrentAndPreviousGameStatesForObjectID(ObjectID, ActionMetadata.StateObject_OldState, ActionMetadata.StateObject_NewState, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	LootDropState = XComGameState_LootDrop(ActionMetadata.StateObject_NewState);

	ActionMetadata.VisualizeActor = LootDropState.GetVisualizer();

	//Hide the old marker
	LootDropMarker = X2Action_LootDropMarker(class'X2Action_LootDropMarker'.static.AddToVisualizationTree(ActionMetadata, VisualizeStateContext));
	LootDropMarker.LootDropObjectID = ObjectID;
	LootDropMarker.LootExpirationTurnsRemaining = LootDropState.LootExpirationTurnsRemaining;
	LootDropMarker.LootLocation = LootDropState.GetLootLocation();
	LootDropMarker.SetVisible = false;

	//stop any effects
	LootExpiredEffectAction = X2Action_PlayEffect(class'X2Action_PlayEffect'.static.AddToVisualizationTree(ActionMetadata, VisualizeStateContext));
	EffectLocationTile = LootDropState.GetLootLocation();
	LootExpiredEffectAction.EffectLocation = World.GetPositionFromTileCoordinates(EffectLocationTile);
	LootExpiredEffectAction.EffectName = ContentManager.LootExpiredEffectPathName;
	LootExpiredEffectAction.bStopEffect = false;

	//stop any sounds
	SoundAction = X2Action_StartStopSound(class'X2Action_StartStopSound'.static.AddToVisualizationTree(ActionMetadata, VisualizeStateContext));
	SoundAction.Sound = new class'SoundCue';
	SoundAction.Sound.AkEventOverride = AkEvent'XPACK_SoundCharacterFX.Stop_Templar_Channel_Loot_Loop';
	SoundAction.iAssociatedGameStateObjectId = LootDropState.ObjectID;
	SoundAction.bIsPositional = true;
	SoundAction.vWorldPosition = History.GetVisualizer(LootDropState.ObjectID).Location;
	SoundAction.bStopPersistentSound = true;

}

//************************
//	End of file
//************************