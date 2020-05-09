USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_CONTRACT_UPDATE]
	@ID		INT,
	@CLIENT	INT,
	@NUM	VARCHAR(100),
	@YEAR	VARCHAR(10),
	@TYPE	INT,
	@PAY	INT,
	@DISC	INT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@COND	VARCHAR(250),
	@DATE	SMALLDATETIME = NULL,
	@ID_FOUND	UNIQUEIDENTIFIER = NULL,
	@FOUND_END	SMALLDATETIME = NULL,
	@FIXED		MONEY = NULL
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

		UPDATE dbo.ContractTable
		SET	ContractNumber	=	@NUM,
			ContractYear	=	@YEAR,
			ContractTypeID	=	@TYPE,
			ContractBegin	=	@BEGIN,
			ContractEnd		=	@END,
			ContractConditions	=	@COND,
			ContractPayID	=	@PAY,
			DiscountID		=	@DISC,
			ContractDate = @DATE,
			--ID_FOUNDATION = @ID_FOUND,
			--FOUND_END = @FOUND_END,
			ContractFixed = @FIXED
		WHERE ContractID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_CONTRACT_UPDATE] TO rl_client_contract_u;
GO