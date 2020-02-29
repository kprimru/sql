USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SPEC_KBO]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT 
			ISNULL(ManagerName, SubhostName) AS 'Руководитель', 
			CASE WHEN ManagerName IS NULL THEN NULL ELSE ServiceName END AS 'СИ', 
			a.DistrStr AS 'Дистрибутив', NT_SHORT AS 'Сеть', ClientName AS 'Клиент', SST_SHORT AS 'Тип',
			REVERSE(STUFF(REVERSE(
				(
					SELECT 
						dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + ','
					FROM 
						dbo.RegNodeTable b
						INNER JOIN dbo.SystemTable t ON t.SystemBaseName = b.SystemName
					WHERE a.Complect = b.Complect
						AND b.Service = 0
						AND t.SystemShortName <> a.SystemShortName					
					ORDER BY SystemOrder FOR XML PATH('')
			)), 1, 1, '')) AS [Дополнительные системы]
		FROM 
			--Reg.RegNodeSearchView a WITH(NOEXPAND)		
			dbo.RegNodeComplectClientView a
			--LEFT OUTER JOIN dbo.ClientDistrView c WITH(NOEXPAND) ON c.SystemID = a.SystemID AND DISTR = DistrNumber AND COMP = CompNumber
			--LEFT OUTER JOIN dbo.ClientView d WITH(NOEXPAND) ON d.ClientID = c.ID_CLIENT
		WHERE a.SystemShortName NOT IN ('БО', 'БОс', 'БОВП', 'СвРег')
			AND a.DS_REG = 0
			AND SST_SHORT IN ('СПЕЦ', 'ЛСВ')
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.RegNodeTable z
					WHERE z.Complect = a.Complect
						AND z.Service = 0
						AND z.SystemName = 'BORG'
				)
		ORDER BY ISNULL(ManagerName, ''), 1, 2, 4
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
