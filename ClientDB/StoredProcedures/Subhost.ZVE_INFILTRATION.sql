USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[ZVE_INFILTRATION]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[ZVE_INFILTRATION]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[ZVE_INFILTRATION]
	@SUBHOST	NVARCHAR(16),
	@EMPTY		BIT
WITH RECOMPILE
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
			ClientName, DistrStr, NT_SHORT, SST_SHORT,
			CNT
		FROM
			(
				SELECT SH_CAPTION, SH_NAME, ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder,
					(
						SELECT COUNT(*)
						FROM
							dbo.ClientDutyQuestion a
							INNER JOIN dbo.SystemTable c ON a.SYS = c.SystemNumber
						WHERE a.DISTR = DistrNumber AND a.COMP = CompNumber AND c.HostID = CLIENT.HostID
					) AS CNT
				FROM
					(
						SELECT 'Владивосток' AS SH_CAPTION, '' AS SH_NAME
						UNION ALL
						SELECT 'Славянка' AS CAPTION, 'Л1' AS SubhostName
						UNION ALL
						SELECT 'Находка' AS CAPTION, 'Н1' AS SubhostName
						UNION ALL
						SELECT 'Уссурийск' AS CAPTION, 'У1' AS SubhostName
						UNION ALL
						SELECT 'Артем' AS CAPTION, 'М' AS SubhostName
					) AS SH
					CROSS APPLY
					(
						SELECT ClientName, DistrStr, HostID, DistrNumber, CompNumber, NT_SHORT, SST_SHORT, SystemOrder
						FROM dbo.RegNodeComplectClientView
						WHERE SubhostName = SH_NAME
							AND DS_REG = 0
					) AS CLIENT
			) AS o_O
		WHERE SH_NAME = @SUBHOST
			AND
				(
					@EMPTY = 0
					OR
					@EMPTY = 1 AND CNT = 0
				)
		ORDER BY SystemOrder, DistrNumber, CompNumber, ClientName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[ZVE_INFILTRATION] TO rl_web_subhost;
GO
