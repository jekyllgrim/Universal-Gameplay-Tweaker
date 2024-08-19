class GameplayTweaksHandler : EventHandler 
{
	override void WorldThingSpawned (Worldevent e) 
	{
		let act = e.thing;
		if (!act)
			return;

		if (act.player && act.player.mo && act.player.mo == act)
		{
			act.GiveInventory("MonsterDamageScaler",1);
		}

		if (act.bISMONSTER && act.health > 0)
		{
			let a = act;
			//health
			a.A_SetHealth(a.health * Clamp(ugt_monsterhealthmul,0,10000));
			a.StartHealth = a.health;
			//size
			double sizemul = Clamp(ugt_monstersizemul,0.1,20);
			Vector2 defsize = (a.radius, a.height);
			a.A_SetSize(a.radius * sizemul,a.height * sizemul);
			// Revert size if doesn't fit:
			if (!a.TestMobjLocation())
			{
				a.A_SetSize(defsize.x, defsize.y);
			}
			else
			{
				a.scale *= sizemul;
			}
			//reaction
			a.ReactionTime = round( double(a.ReactionTime) * Clamp(ugt_monsterreaction, 0.0, 100.0) );
			//attack frequency
			a.MinMissileChance = round( double(a.MinMissileChance) * Clamp(ugt_monsterreaction, 0.0, 100.0) );
			//Console.Printf("%s MinMissileChance def: %d | now: %d", a.GetClassName(), GetDefaultByType(a.GetClass()).MinMissileChance, a.MinMissileChance);
			//speed
			a.speed *= Clamp(ugt_monsterspeedmul,0,100);
			//fast monsters
			switch (ugt_fastmonsters)
			{
			case 1:
				a.bALWAYSFAST = true;
				break;
			case 2:
				a.bNEVERFAST = true;
				break;
			}
			//monster respawn
			switch (ugt_monstersrespawn)
			{
			case 1:
				a.bALWAYSRESPAWN = true;
				break;
			case 2:
				a.bNEVERRESPAWN = true;
				break;
			}
		}

		if (act.bMISSILE && act.target && act.target.bISMONSTER)
		{
			act.A_ScaleVelocity(ugt_monstersprojvel);
		}

		else if (act is "Inventory") 
		{
			if (act is "Ammo") 
			{
				let am = Ammo(act);
				if (am)
					am.amount *= Clamp(ugt_ammoamountmul,0,100);
			}
			else if (act is "Health") 
			{
				let he = Health(act);
				if (he) 
				{
					he.amount *= Clamp(ugt_medamountmul,0,100);
					he.maxamount *= Clamp(ugt_medamountmul,0,100);
				}
			}
			else if (act is "BasicArmorBonus") 
			{
				let arm = BasicArmorBonus(act);
				if (arm) 
				{
					arm.saveamount *= Clamp(ugt_armoramountmul,0,100);
					arm.savepercent = Clamp(arm.savepercent * ugt_armorsavemul,0,100);
				}
			}
			else if (act is "BasicArmorPickup") 
			{
				let arm = BasicArmorPickup(act);
				if (arm) 
				{
					arm.saveamount *= Clamp(ugt_armoramountmul,0,100);
					arm.savepercent = Clamp(arm.savepercent * ugt_armorsavemul,0,100);
				}
			}
			else if (act is "PowerupGiver") 
			{
				let pw = PowerupGiver(act);
				pw.EffectTics *= Clamp(ugt_powerupmul,1,100);
			}
		}
	}
}

Class MonsterDamageScaler : Inventory 
{
	Default 
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		inventory.maxamount 1;
	}

	override void Tick() {}
	
	override void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) 
	{
		if (!source || !owner || !passive)
			return;
		if (source.bISMONSTER && source.IsHostile(owner))
			newdamage = Clamp(damage * ugt_monsterdamagemul,0,10000);
	}
}