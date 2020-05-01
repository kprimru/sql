USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_INSERT]
	@CLIENT	INT,
	@NUM	VARCHAR(100),
	@YEAR	VARCHAR(10),
	@TYPE	INT,
	@PAY	INT,
	@DISC	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@COND	VARCHAR(250),
	@ID	INT = NULL OUTPUT,
	@DATE	SMALLDATETIME = NULL,
	@ID_FOUND	UNIQUEIDENTIFIER = NULL,
	@FOUND_END	SMALLDATETIME = NULL,
	@FIXED		MONEY	= NULL
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

		INSERT INTO dbo.ContractTable(
					ClientID, ContractNumber, ContractYear, ContractTypeID, ContractBegin,
					ContractEnd, ContractConditions, ContractPayID, DiscountID, ContractDate,
					ID_FOUNDATION, FOUND_END, ContractFixed)
			VALUES(@CLIENT, @NUM, @YEAR, @TYPE, @BEGIN, @END, @COND, @PAY, @DISC, @DATE, @ID_FOUND, @FOUND_END, @FIXED)

		SELECT @ID = SCOPE_IDENTITY()

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_INSERT] TO rl_client_contract_i;
GO