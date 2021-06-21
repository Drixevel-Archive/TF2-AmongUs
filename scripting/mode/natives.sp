/*****************************/
//Natives

public int Native_GameSettings_Parse(Handle plugin, int numParams)
{
	ParseGameSettings();
}

public int Native_GameSettings_GetInt(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);

	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return GetGameSetting_Int(sSetting);
}

public int Native_GameSettings_SetInt(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);
	
	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return SetGameSetting_Int(sSetting, GetNativeCell(2));
}

public int Native_GameSettings_GetFloat(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);

	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return view_as<any>(GetGameSetting_Float(sSetting));
}

public int Native_GameSettings_SetFloat(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);
	
	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return SetGameSetting_Float(sSetting, GetNativeCell(2));
}

public int Native_GameSettings_GetString(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);

	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	size = GetNativeCell(3);

	char[] sValue = new char[size];
	bool found = GetGameSetting_String(sSetting, sValue, size);

	SetNativeString(2, sValue, size);

	return found;
}

public int Native_GameSettings_SetString(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);
	
	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	GetNativeStringLength(2, size);
	
	char[] sValue = new char[size];
	GetNativeString(2, sValue, size);

	return SetGameSetting_String(sSetting, sValue);
}

public int Native_GameSettings_GetBool(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);

	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return GetGameSetting_Bool(sSetting);
}

public int Native_GameSettings_SetBool(Handle plugin, int numParams)
{
	int size;
	GetNativeStringLength(1, size);
	
	char[] sSetting = new char[size];
	GetNativeString(1, sSetting, size);

	return SetGameSetting_Bool(sSetting, GetNativeCell(2));
}

public int Native_GameSettings_SaveClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	SaveGameSettings(client);
}

public int Native_GameSettings_LoadClient(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	LoadGameSettings(client);
}