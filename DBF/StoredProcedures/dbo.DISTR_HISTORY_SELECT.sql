USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_HISTORY_SELECT]
	@CL_ID	INT
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

		IF @CL_ID IS NULL
		BEGIN
			SELECT DDH_ID, DIS_STR, CL_OLD_ID, CL_OLD_PSEDO, CL_NEW_ID, CL_NEW_PSEDO, DDH_NOTE, DDH_USER, DDH_DATE
			FROM dbo.DistrHistoryView
			ORDER BY DDH_DATE
		END
		ELSE
		BEGIN
			SELECT DDH_ID, DIS_STR, CL_OLD_ID, CL_OLD_PSEDO, CL_NEW_ID, CL_NEW_PSEDO, DDH_NOTE, DDH_USER, DDH_DATE
			FROM dbo.DistrHistoryView
			WHERE CL_OLD_ID = @CL_ID OR CL_NEW_ID = @CL_ID
			ORDER BY DDH_DATE
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_HISTORY_SELECT] TO rl_client_distr_w;
GRANT EXECUTE ON [dbo].[DISTR_HISTORY_SELECT] TO rl_distr_financing_r;
GO
