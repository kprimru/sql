USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[DIU_UNSET]
	@SYS	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@DATE	SMALLDATETIME
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

		UPDATE Subhost.Diu
		SET DIU_ACTIVE = 0,
			DIU_LAST = @DATE
		WHERE DIU_ID_SYSTEM = @SYS
			AND DIU_DISTR = @DISTR
			AND DIU_COMP = @COMP
			AND DIU_ACTIVE = 1

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[DIU_UNSET] TO rl_subhost_calc;
GO