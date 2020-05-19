version "4.3.0"

class GameplayTweaksHandler : EventHandler {
	override void WorldTick() {
		if (ugt_resetall) {
			CVar.GetCVar('ugt_monsterhealthmul').ResetToDefault();
			CVar.GetCVar('ugt_monsterdamagemul').ResetToDefault();
			CVar.GetCVar('ugt_monstersizemul').ResetToDefault();
			CVar.GetCVar('ugt_monsterspeedmul').ResetToDefault();
			CVar.GetCVar('ugt_fastmonsters').ResetToDefault();
			CVar.GetCVar('ugt_monstersrespawn').ResetToDefault();
			CVar.GetCVar('ugt_monstersprojvel').ResetToDefault();
			CVar.GetCVar('ugt_medamountmul').ResetToDefault();
			CVar.GetCVar('ugt_ammoamountmul').ResetToDefault();
			CVar.GetCVar('ugt_armoramountmul').ResetToDefault();
			CVar.GetCVar('ugt_armorsavemul').ResetToDefault();
			CVar.GetCVar('ugt_powerupmul').ResetToDefault();
			CVar.GetCVar('ugt_resetall').ResetToDefault();
		}
	}
	override void WorldThingSpawned (Worldevent e) {
		if (!e.thing)
			return;
		let act = e.thing;
		if (act.player)
			act.GiveInventory("MonsterDamageScaler",1);
		if (act.bISMONSTER) {
			let a = act;
			//health
			a.A_SetHealth(a.health * Clamp(ugt_monsterhealthmul,0,10000));
			//size
			double sizemul = Clamp(ugt_monstersizemul,0.1,20);
			a.scale *= sizemul;
			a.A_SetSize(a.radius * sizemul,a.height * sizemul);
			//speed
			a.speed *= Clamp(ugt_monsterspeedmul,0,100);
			//fast monsters
			if (ugt_fastmonsters == 1)
				a.bALWAYSFAST = true;
			else if (ugt_fastmonsters > 1)
				a.bNEVERFAST = true;
			//monster respawn
			if (ugt_monstersrespawn == 1)
				a.bALWAYSRESPAWN = true;
			else if (ugt_monstersrespawn > 1)
				a.bNEVERRESPAWN = true;			
		}
		if (act.bMISSILE && act.target && act.target.bISMONSTER)
			act.A_ScaleVelocity(ugt_monstersprojvel);
		else if (act is "Inventory") {			
			if (act is "Ammo") {
				let am = Ammo(act);
				if (am)
					am.amount *= Clamp(ugt_ammoamountmul,0,100);
			}
			else if (act is "Health") {
				let he = Health(act);
				if (he) {
					he.amount *= Clamp(ugt_medamountmul,0,100);
					he.maxamount *= Clamp(ugt_medamountmul,0,100);
				}
			}
			else if (act is "BasicArmorBonus") {
				let arm = BasicArmorBonus(act);
				if (arm) {
					arm.saveamount *= Clamp(ugt_armoramountmul,0,100);
					arm.savepercent = Clamp(arm.savepercent * ugt_armorsavemul,0,100);
					//console.printf("%s, perc %d",e.thing.GetClassName(),arm.savepercent);
				}
			}
			else if (act is "BasicArmorPickup") {
				let arm = BasicArmorPickup(act);
				if (arm) {
					arm.saveamount *= Clamp(ugt_armoramountmul,0,100);
					arm.savepercent = Clamp(arm.savepercent * ugt_armorsavemul,0,100);
					//console.printf("%s, perc %d",e.thing.GetClassName(),arm.savepercent);
				}
			}
			else if (act is "PowerupGiver") {
				let pw = PowerupGiver(act);
				pw.EffectTics *= Clamp(ugt_powerupmul,1,100);
			}
		}
	}
}

Class MonsterDamageScaler : Inventory {
	Default {
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		inventory.maxamount 1;
	}
	override void Tick() {}
	override void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) {
		if (!source || !owner || !passive)
			return;
		if (source.bISMONSTER && !source.bFRIENDLY)
			newdamage = Clamp(damage * ugt_monsterdamagemul,0,10000);
		//Console.Printf("%s, expected: %d, dealt: %d",source.GetClassName(),damage,newdamage);
	}
}