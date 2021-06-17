/*****************************/
//Commands

public Action Command_ReloadColors(int client, int args)
{
	ParseColors();
	CPrintToChat(client, "Colors have been reloaded.");
	return Plugin_Handled;
}