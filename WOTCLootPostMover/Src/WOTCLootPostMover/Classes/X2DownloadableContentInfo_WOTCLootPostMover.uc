//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_WOTCLootPostMover.uc                                    
//           
//	Created by RustyDios	18/03/20	09:00
//	Last Updated			22/03/20	17:00
//
//	Changes the static meshes of the lost post actors to move them to the edges
//		CODE Assistance provided by X2Maneck/Astral Descend for the CDO override
//
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_WOTCLootPostMover extends X2DownloadableContentInfo config (LootPostMover);

//grab config stuffs
var config bool bEnableLogging;
var config bool bLootExpirationEnabled;
var config int iLootExpirationMaxTurns;
var config int iLootExpirationMaxTurns_Psi;

//empty dlc2 info
static event OnLoadedSavedGame(){}

static event InstallNewCampaign(XComGameState StartState){}

static event OnPostTemplatesCreated()
{
	local XComLootDropActor Goalposts;

	//grab the games loot post actor
	Goalposts = XComLootDropActor(class'XComEngine'.static.GetClassDefaultObject(class 'XcomLootDropActor'));

	//change the mesh refs to the new meshes
	//StaticMesh(`CONTENT.RequestGameArchetype("LootableGoalPostsMoved.LootStatusNew"));
	//StaticMesh(`CONTENT.RequestGameArchetype("LootableGoalPostsMoved.LootStatusNewPsi"));
	Goalposts.LootMarkerMesh.SetStaticMesh(StaticMesh(DynamicLoadObject("LootableGoalPostsMoved.LootStatusNew", class'StaticMesh')), true);
	Goalposts.PsiLootMarkerMesh.SetStaticMesh(StaticMesh(DynamicLoadObject("LootableGoalPostsMoved.LootStatusNewPsi", class'StaticMesh')), true);

	//report change to the log
	`log("Loot actor patched",default.bEnableLogging, 'WOTCLootPostMover');

}
