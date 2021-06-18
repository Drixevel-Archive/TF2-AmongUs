/*****************************/
//Utils

/////
//Roles

void GetRoleName(Roles role, char[] buffer, int size)
{
	switch (role)
	{
		case Role_Crewmate:
			strcopy(buffer, size, "Crewmate");
		case Role_Imposter:
			strcopy(buffer, size, "Imposter");
	}
}

bool IsValidRole(const char[] name)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (StrEqual(sRole, name, false))
			return true;
	}

	return false;
}

void RoleNamesBuffer(char[] buffer, int size)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (i == Role_Crewmate)
			FormatEx(buffer, size, "%s", sRole);
		else
			Format(buffer, size, "%s, %s", buffer, sRole);
	}
}

Roles GetRoleByName(const char[] name)
{
	char sRole[32];
	for (Roles i = Role_Crewmate; i < Role_Total; i++)
	{
		GetRoleName(i, sRole, sizeof(sRole));

		if (StrEqual(sRole, name, false))
			return i;
	}

	//Return -1 which just means this role wasn't found.
	return view_as<Roles>(-1);
}