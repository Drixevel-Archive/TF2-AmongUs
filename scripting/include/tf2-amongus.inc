#if defined _tf2_amongus_ 
	#endinput
#endif 
#define _tf2_amongus_

/**
 * Called whenever a set of game settings has been parsed successfully.
 *
 * @return           N/A
 */
forward void GameSettings_OnParsed();

/**
 * Called whenever a clients game settings have been saved.
 *
 * @param client     Client index.
 * @return           N/A
 */
forward void GameSettings_OnSaveClient(int client);

/**
 * Called whenever a clients game settings have been loaded.
 *
 * @param client     Client index.
 * @return           N/A
 */
forward void GameSettings_OnLoadClient(int client);

/**
 * Called whenever a player is set to a certain color.
 *
 * @param client     Client index.
 * @param color      Color index.
 * @return           N/A
 */
forward void AmongUs_OnColorSet(int client, int color);

/**
 * Called whenever a task started by the player.
 *
 * @param client     Client index.
 * @param task       Task index.
 * @param part       Part index if applicable to a task map.
 * @return           N/A
 */
forward void AmongUs_OnTaskStarted(int client, int task, int part);

/**
 * Called whenever a task is completed fully.
 *
 * @param client     Client index.
 * @param task       Task index.
 * @return           N/A
 */
forward void AmongUs_OnTaskCompleted(int client, int task);

/**
 * Called whenever a sabotage has been started.
 *
 * @param client     Client index.
 * @param sabotage   Sabotage index.
 * @return           N/A
 */
forward void AmongUs_OnSabotageStarted(int client, int sabotage);

//Methodmaps
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
public __pl_tf2_amongus_SetNTVOptional()
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

public SharedPlugin __pl_tf2_amongus = 
{
	name = "tf2-amongus",
	file = "tf2-amongus.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};