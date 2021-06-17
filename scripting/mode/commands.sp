/*****************************/
//Commands

public Action Command_Colors(int client, int args)
{
	if (client == 0)
		return Plugin_Handled;
	
	OpenColorsMenu(client);
	return Plugin_Handled;
}

public Action Command_ReloadColors(int client, int args)
{
	ParseColors();
	CReplyToCommand(client, "Colors have been reloaded.");
	return Plugin_Handled;
}