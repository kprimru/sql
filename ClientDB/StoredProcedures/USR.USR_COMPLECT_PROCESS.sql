USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[USR_COMPLECT_PROCESS]
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE USR.USRData
	SET UD_ID_CLIENT = 
		(
			SELECT TOP 1 ID_CLIENT
			FROM 
				dbo.ClientDistrView WITH(NOEXPAND)
				INNER JOIN USR.USRPackage ON UP_ID_SYSTEM = SystemID AND UP_DISTR = DISTR AND UP_COMP = COMP
				INNER JOIN USR.USRFile ON UF_ID = UP_ID_USR
			WHERE UF_ID_COMPLECT = UD_ID
			ORDER BY SystemOrder, DISTR, COMP
		)
	WHERE UD_ID_CLIENT IS NULL
		AND EXISTS
			(
				SELECT *
				FROM 
					dbo.ClientDistrView WITH(NOEXPAND)
					INNER JOIN USR.USRPackage ON UP_ID_SYSTEM = SystemID AND UP_DISTR = DISTR AND UP_COMP = COMP
					INNER JOIN USR.USRFile ON UF_ID = UP_ID_USR
				WHERE UF_ID_COMPLECT = UD_ID
			)
END
