﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USRActiveView?Cache]', 'V ') IS NULL EXEC('CREATE VIEW [USR].[USRActiveView?Cache]  AS SELECT 1')
GO
ALTER VIEW [USR].[USRActiveView?Cache]
AS
	SELECT
		UD_ID, UF_ID, UD_DISTR, UD_COMP,
		UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UD_ID_CLIENT,
		UF_CREATE, UF_PATH, UD_ACTIVE, UF_ID_SYSTEM, UD_ID_HOST
	FROM USR.USRData
	CROSS APPLY
	(
		SELECT TOP 1
			UF_ID, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE,
			UF_CREATE, UF_PATH, UF_ID_SYSTEM
		FROM USR.USRFile
		INNER JOIN dbo.USRFileKindTable ON USRFileKindID = UF_ID_KIND
		WHERE UF_ID_COMPLECT = UD_ID AND UF_ACTIVE = 1
		ORDER BY UF_DATE DESC, UF_CREATE DESC
	) AS UF
	WHERE UD_ACTIVE = 1
GO
