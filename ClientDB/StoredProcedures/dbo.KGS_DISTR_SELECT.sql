USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[KGS_DISTR_SELECT]
	@ID	INT
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
			KD_ID,
			dbo.DistrString(SystemShortName, KD_DISTR, KD_COMP) AS DIS_STR,
			KD_ID_SYS, KD_DISTR, KD_COMP
		FROM
			dbo.KGSDistr
			INNER JOIN dbo.SystemTable ON KD_ID_SYS = SystemID
		WHERE KD_ID_LIST = @ID
		ORDER BY SystemOrder, KD_DISTR

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[KGS_DISTR_SELECT] TO rl_kgs_distr_r;
GO
