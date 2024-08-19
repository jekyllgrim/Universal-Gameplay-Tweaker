class OptionMenuItemUGT_ConfirmCommand : OptionMenuItemSubmenu
{
	String mPrompt;

	static const name ugtcvars[] =
	{
		'ugt_monsterhealthmul',
		'ugt_monsterdamagemul',
		'ugt_monstersizemul',
		'ugt_monsterspeedmul',
		'ugt_fastmonsters',
		'ugt_monstersrespawn',
		'ugt_monstersprojvel',
		'ugt_monsterreaction',
		'ugt_monsterattackfreq',
		'ugt_medamountmul',
		'ugt_ammoamountmul',
		'ugt_armoramountmul',
		'ugt_armorsavemul',
		'ugt_powerupmul'
	};

	OptionMenuItemUGT_ConfirmCommand Init(String label, String prompt = "")
	{
		Super.Init(label, "");
		mPrompt = StringTable.Localize(prompt);
		return self;
	}

	override bool MenuEvent (int mkey, bool fromcontroller)
	{
		if (mkey == Menu.MKEY_MBYes)
		{
			CVar c;
			for (int i = 0; i < ugtcvars.Size(); i++)
			{
				c = CVar.FindCVar(ugtcvars[i]);
				if (c)
				{
					c.ResetToDefault();
				}
			}
			return true;
		}
		return Super.MenuEvent(mkey, fromcontroller);
	}
	
	override bool Activate()
	{
		Menu.StartMessage(TEXTCOLOR_NORMAL..mPrompt, 0);
		return true;
	}
}