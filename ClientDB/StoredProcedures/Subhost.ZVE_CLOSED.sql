USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[ZVE_CLOSED]
	@SUBHOST	NVARCHAR(16)
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

		SELECT ClientName, DistrStr, NT_SHORT , SST_SHORT
		FROM dbo.RegNodeComplectClientView a
		WHERE a.DS_REG = 0
			AND NOT EXISTS
			(
				SELECT *
				FROM dbo.ExpertDistr b
				WHERE a.HostID = b.ID_HOST
					AND a.DistrNumber = b.DISTR
					AND a.CompNumber = b.COMP
					AND b.STATUS = 1
					AND b.UNSET_DATE IS NULL
			)
			--AND SST_SHORT NOT IN ('дхс', 'юдл', 'дяо', 'кяб', 'ндд')
			AND NT_SHORT NOT IN ('нбо', 'нбох', 'нбл1', 'нбл2', 'нбй')
			AND SubhostName = @SUBHOST
		ORDER BY ClientName

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[ZVE_CLOSED] TO rl_web_subhost;
GO