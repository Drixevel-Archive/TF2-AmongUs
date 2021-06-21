#if defined _mode_amongus_ 
	#endinput
#endif 
#define _mode_amongus_

forward void GameSettings_OnParsed();
forward void GameSettings_OnSaveClient(int client);
forward void GameSettings_OnLoadClient(int client);

methodmap GameSettings
{
	public GameSettings()
	{
		return view_as<GameSettings>(-1);
	}

	public native void Parse();
	public native int GetInt(const char[] setting);
	public native bool SetInt(const char[] setting, int value);
	public native float GetFloat(const char[] setting);
	public native bool SetFloat(const char[] setting, float value);
	public native bool GetString(const char[] setting, const char[] buffer, int size);
	public native bool SetString(const char[] setting, char[] buffer);
	public native bool GetBool(const char[] setting);
	public native bool SetBool(const char[] setting, bool value);
	public native void SaveClient(int client);
	public native void LoadClient(int client);
}

#if !defined REQUIRE_PLUGIN
public __pl_mode_amongus_SetNTVOptional()
{
	MarkNativeAsOptional("GameSettings.Parse");
	MarkNativeAsOptional("GameSettings.GetInt");
	MarkNativeAsOptional("GameSettings.SetInt");
	MarkNativeAsOptional("GameSettings.GetFloat");
	MarkNativeAsOptional("GameSettings.SetFloat");
	MarkNativeAsOptional("GameSettings.GetString");
	MarkNativeAsOptional("GameSettings.SetString");
	MarkNativeAsOptional("GameSettings.GetBool");
	MarkNativeAsOptional("GameSettings.SetBool");
	MarkNativeAsOptional("GameSettings.SaveClient");
	MarkNativeAsOptional("GameSettings.LoadClient");
}
#endif  

public SharedPlugin __pl_mode_amongus = 
{
	name = "mode-amongus",
	file = "mode-amongus.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};