USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Reg].[DISTR_HISTORY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Reg].[DISTR_HISTORY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Reg].[DISTR_HISTORY_SELECT]
	@ID		UNIQUEIDENTIFIER	= NULL,
	@STR	VARCHAR(50)			= NULL OUTPUT,
	@HST	INT					= NULL,
	@DISTR	INT					= NULL,
	@COMP	TINYINT				= NULL
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

		IF @ID IS NOT NULL
			SELECT
				@HST = HostID, @DISTR = DISTR, @COMP = COMP,
				@STR = DistrStr
			FROM dbo.ClientDistrView a WITH(NOEXPAND)
			WHERE ID = @ID
		ELSE
			SELECT @STR = DistrStr
			FROM
				Reg.RegNodeSearchView a WITH(NOEXPAND)
				INNER JOIN dbo.SystemTable b ON a.SystemID = b.SystemID
			WHERE b.HostID = @HST AND DistrNumber = @DISTR AND CompNumber = @COMP

		SELECT b.DATE, b.SystemShortName, DS_NAME, SST_SHORT, NT_SHORT, TRAN_COUNT, TRAN_LEFT, REG_DATE, COMPLECT, COMMENT, CHANGES
		FROM
			Reg.RegDistr a
			INNER JOIN Reg.RegHistoryView b WITH(NOEXPAND)ON a.ID = b.ID_DISTR
			OUTER APPLY
			(
			    SELECT TOP (1) e.CHANGES
			    FROM Reg.RegHistoryOperationView e
			    WHERE e.ID = b.ID
			        AND e.ID_DISTR = b.ID_DISTR
			) AS e
		WHERE ID_HOST = @HST AND DISTR = @DISTR AND COMP = @COMP
		ORDER BY DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Reg].[DISTR_HISTORY_SELECT] TO rl_client_distr_protocol;
GRANT EXECUTE ON [Reg].[DISTR_HISTORY_SELECT] TO rl_client_system_protocol;
GO
