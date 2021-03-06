USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_FINANCING_SAVE]
	@ID INT,
	@BILL_GROUP BIT,
	@BILL_MASS_PRINT BIT = 1,
	@UNKNOWN	BIT = 0,
	@UPD_PRINT  BIT = 0,
	@EIS_CODE   VarChar(256) = NULL,
	@EIS_CONTRACT VarChar(100) = NULL,
	@EIS_REG_NUM VarChar(100) = NULL,
	@EIS_DATA NVarChar(Max) = NULL
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

        SET @EIS_CODE = NULLIF(RTRIM(LTRIM(@EIS_CODE)), '');

		UPDATE dbo.ClientFinancing
		SET BILL_GROUP = @BILL_GROUP,
			BILL_MASS_PRINT = @BILL_MASS_PRINT,
			UNKNOWN_FINANCING = @UNKNOWN,
			EIS_CODE = @EIS_CODE,
			EIS_DATA = @EIS_DATA,
			EIS_CONTRACT = @EIS_CONTRACT,
			EIS_REG_NUM = @EIS_REG_NUM,
			UPD_PRINT = @UPD_PRINT
		WHERE ID_CLIENT = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_FINANCING_SAVE] TO rl_distr_financing_w;
GO