USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [USR].[PROCESS_FILE_REPORT]
	@sessionid VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT
		UF_NAME, USRFileKindShortName, ClientFullName, ServiceName, UF_DATE,
		REVERSE(STUFF(REVERSE((
			SELECT SystemShortName + ' (' + CONVERT(VARCHAR(20), MAX(UI_LAST), 104), + '), '
			FROM 
				(
					SELECT SystemShortName, UP_DISTR, UP_COMP, SystemOrder, InfoBankOrder, InfoBankID
					FROM
						USR.USRPackage
						INNER JOIN dbo.SystemBanksView WITH(NOEXPAND) ON SystemID = UP_ID_SYSTEM
					WHERE UP_ID_USR = UF_ID
					
					UNION 
					
					SELECT SystemShortName, UP_DISTR, UP_COMP, z.SystemOrder, InfoBankOrder, InfoBankID
					FROM
						USR.USRPackage
						INNER JOIN dbo.SystemTable z ON z.SystemID = UP_ID_SYSTEM
						INNER JOIN dbo.DistrConditionView y ON UP_ID_SYSTEM = y.SystemID 
															AND UP_DISTR = DistrNumber 
															AND UP_COMP = CompNumber										
					WHERE UP_ID_USR = UF_ID	
				) AS t
				LEFT OUTER JOIN USR.USRIB ON UI_ID_BASE = InfoBankID AND UI_DISTR = UP_DISTR AND UI_COMP = UP_COMP
			WHERE UI_ID_USR = UF_ID
			GROUP BY SystemShortName, SystemOrder
			ORDER BY SystemOrder FOR XML PATH('')
		)), 1, 2, '')) AS SYS_LIST
	FROM 
		USR.USRFile
		INNER JOIN USR.USRData ON UD_ID = UF_ID_COMPLECT
		INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
		LEFT OUTER JOIN dbo.ClientView WITH(NOEXPAND) ON ClientID = UD_ID_CLIENT
	WHERE UF_SESSION = @sessionid
	ORDER BY ServiceName, ClientFullName, UF_NAME
END