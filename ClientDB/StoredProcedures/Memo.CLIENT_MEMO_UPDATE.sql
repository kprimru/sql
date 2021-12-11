USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_MEMO_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_MEMO_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@CLIENT	INT,
	@CONTRACT	NVARCHAR(512),
	@DISTR		NVARCHAR(MAX),
	@DOC_TYPE	UNIQUEIDENTIFIER,
	@SERVICE	UNIQUEIDENTIFIER,
	@VENDOR		UNIQUEIDENTIFIER,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@MONTH		MONEY,
	@PERIOD		MONEY,
	@PER_START	SMALLDATETIME,
	@PER_END	SMALLDATETIME,
	@PER_FULL	MONEY,
	@PAY_TYPE	INT,
	@FRAMEWORK	NVARCHAR(1024),
	@DOCUMENTS	NVARCHAR(1024),
	@CANCEL		BIT,
	@SYSTEM		NVARCHAR(MAX) = NULL,
	@ID_CONTRACT_PAY INT = NULL,
	@Contract_Id        UniqueIdentifier = NULL,
	@SPECIFICATIONS NVarChar(Max) = NULL,
	@ADDITIONALS    NVarChar(Max) = NULL
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

		UPDATE Memo.ClientMemo
		SET	CURRENT_CONTRACT	=	@CONTRACT,
			DISTR				=	@DISTR,
			ID_DOC_TYPE			=	@DOC_TYPE,
			ID_SERVICE			=	@SERVICE,
			ID_VENDOR			=	@VENDOR,
			Contract_Id         = @Contract_Id,
			START				=	@START,
			FINISH				=	@FINISH,
			MONTH_PRICE			=	@MONTH,
			PERIOD_PRICE		=	@PERIOD,
			PERIOD_START		=	@PER_START,
			PERIOD_END			=	@PER_END,
			PERIOD_FULL_PRICE	=	@PER_FULL,
			ID_PAY_TYPE			=	@PAY_TYPE,
			ID_CONTRACT_PAY_TYPE = @ID_CONTRACT_PAY,
			FRAMEWORK			=	@FRAMEWORK,
			DOCUMENTS			=	@DOCUMENTS,
			LETTER_CANCEL		=	@CANCEL,
			SYSTEMS				=	@SYSTEM
		WHERE ID = @ID

		DELETE FROM Memo.ClientMemoConditions
		WHERE ID_MEMO = @ID

		DELETE FROM Memo.ClientMemoAdditionals
		WHERE Memo_Id = @ID

		DELETE FROM Memo.ClientMemoSpecifications
		WHERE Memo_Id = @ID

		INSERT INTO Memo.ClientMemoSpecifications
		SELECT @ID, Id
		FROM dbo.TableGUIDFromXML(@SPECIFICATIONS) AS I

		INSERT INTO Memo.ClientMemoAdditionals
		SELECT @ID, Id
		FROM dbo.TableGUIDFromXML(@ADDITIONALS) AS I

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_UPDATE] TO rl_client_memo_u;
GO
