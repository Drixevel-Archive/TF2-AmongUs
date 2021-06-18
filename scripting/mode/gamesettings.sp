/*****************************/
//Game Settings

void ParseGameSettings()
{
	g_GameSettings.Clear();

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/amongus/settings.cfg");

	KeyValues kv = new KeyValues("settings");

	if (kv.ImportFromFile(sPath) && kv.GotoFirstSubKey(false))
	{
		do
		{
			char sSetting[32];
			kv.GetSectionName(sSetting, sizeof(sSetting));

			char sValue[32];
			kv.GetString(NULL_STRING, sValue, sizeof(sValue));

			g_GameSettings.SetString(sSetting, sValue);
		}
		while (kv.GotoNextKey(false));
	}

	delete kv;
	LogMessage("%i game settings loaded.", g_GameSettings.Size);
}

stock int GetGameSetting_Int(const char[] setting)
{
	char sValue[32];
	g_GameSettings.GetString(setting, sValue, sizeof(sValue));
	return StringToInt(sValue);
}

stock bool SetGameSetting_Int(const char[] setting, int value)
{
	char sValue[32];
	IntToString(value, sValue, sizeof(sValue));
	return g_GameSettings.SetString(setting, sValue);
}

stock float GetGameSetting_Float(const char[] setting)
{
	char sValue[32];
	g_GameSettings.GetString(setting, sValue, sizeof(sValue));
	return StringToFloat(sValue);
}

stock bool SetGameSetting_Float(const char[] setting, float value)
{
	char sValue[32];
	FloatToString(value, sValue, sizeof(sValue));
	return g_GameSettings.SetString(setting, sValue, sizeof(sValue));
}

stock bool GetGameSetting_String(const char[] setting, char[] buffer, int size)
{
	char sValue[32];
	return g_GameSettings.GetString(setting, buffer, size);
}

stock bool SetGameSetting_String(const char[] setting, const char[] buffer)
{
	return g_GameSettings.SetString(setting, buffer);
}

stock int GetGameSetting_Bool(const char[] setting)
{
	char sValue[32];
	g_GameSettings.GetString(setting, sValue, sizeof(sValue));
	return view_as<bool>(StringToInt(sValue));
}

stock bool SetGameSetting_Bool(const char[] setting, bool value)
{
	char sValue[32];
	IntToString(view_as<int>(value), sValue, sizeof(sValue));
	return g_GameSettings.SetString(setting, sValue);
}