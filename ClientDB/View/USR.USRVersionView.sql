USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[USRVersionView]', 'V ') IS NULL EXEC('CREATE VIEW [USR].[USRVersionView]  AS SELECT 1')
GO
ALTER VIEW [USR].[USRVersionView]
AS
	SELECT f.UF_ID, UD_ID_CLIENT, UF_DATE, ResVersionNumber, ResVersionShort, ConsExeVersionName
	FROM
		USR.USRData
		INNER JOIN USR.USRFile f ON UF_ID_COMPLECT = UD_ID
		INNER JOIN USR.USRFileTech t ON f.UF_ID = t.UF_ID
		INNER JOIN dbo.ResVersionTable ON ResVersionID = t.UF_ID_RES
		INNER JOIN dbo.ConsExeVersionTable ON ConsExeVersionID = t.UF_ID_CONS
	WHERE UF_PATH <> 3 AND UF_ACTIVE = 1 AND UD_ACTIVE = 1
		AND
			(
				(UF_DATE > ResVersionEnd AND ResVersionEnd IS NOT NULL)
				OR (UF_DATE > ConsExeVersionEnd AND ConsExeVersionEnd IS NOT NULL)
			)
GO
