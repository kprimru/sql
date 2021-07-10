USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_PAY_EDIT]
	@SHP_ID	INT,
	@ORG_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@DATE	SMALLDATETIME,
	@SUM	MONEY,
	@COMMENT	VARCHAR(200)
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

		DECLARE @SH_ID SMALLINT

		SELECT @SH_ID = SHP_ID_SUBHOST
		FROM Subhost.SubhostPay
		WHERE SHP_ID = @SHP_ID

		EXEC Subhost.SUBHOST_PAY_DELETE @SHP_ID

		EXEC Subhost.SUBHOST_PAY_ADD @SH_ID, @ORG_ID, @PR_ID, @DATE, @SUM, @COMMENT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_PAY_EDIT] TO rl_subhost_calc;
GO