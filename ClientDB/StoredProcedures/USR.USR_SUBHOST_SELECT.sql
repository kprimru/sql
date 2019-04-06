USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USR].[USR_SUBHOST_SELECT]
	@SH_ID	VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @REG	VARCHAR(50)

	SELECT @REG = '(' + SH_REG + ')%' 
	FROM dbo.Subhost
	WHERE SH_ID = CONVERT(UNIQUEIDENTIFIER, @SH_ID)

	SELECT 
		UD_ID, UF_DATA, UF_NAME
	FROM 
		(
			SELECT UD_ID
			FROM
				USR.USRComplectNumberView a WITH(NOEXPAND)
				INNER JOIN	dbo.SystemTable c ON a.UD_SYS = c.SystemNumber
				INNER JOIN	dbo.RegNodeTable b ON b.SystemName = c.SystemBaseName							
								AND 
									a.UD_DISTR = DistrNumber
								AND 
									a.UD_COMP = CompNumber
			WHERE Comment LIKE @REG

			UNION

			SELECT UD_ID
			FROM 
				USR.USRComplectNumberView a WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable ON UD_SYS = SystemNumber
				INNER JOIN dbo.SubhostComplect ON SC_ID_HOST = HostID AND UD_DISTR = SC_DISTR AND UD_COMP = SC_COMP				
			WHERE SC_ID_SUBHOST = @SH_ID
		) AS o_O
		CROSS APPLY
		(
			SELECT TOP 1 d.UF_DATA, UF_NAME
			FROM USR.USRFile f
			INNER JOIN USR.USRFileData d ON f.UF_ID = d.UF_ID
			WHERE UF_ID_COMPLECT = UD_ID
				AND UF_PATH = 2
			ORDER BY UF_CREATE DESC
		) AS F
	WHERE EXISTS
			(
				SELECT *
				FROM USR.USRFile
				WHERE UF_ID_COMPLECT = UD_ID
					AND UF_PATH = 2
					AND UF_CREATE >= DATEADD(MONTH, -1, GETDATE())
			)
END