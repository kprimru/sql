﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Memo].[CLIENT_MEMO_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Memo].[CLIENT_MEMO_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Memo].[CLIENT_MEMO_INSERT]
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
	@SYSTEM		NVARCHAR(MAX),
	@ID			UNIQUEIDENTIFIER = NULL OUTPUT,
	@ID_CONTRACT_PAY	INT = NULL,
	@Contract_Id    UniqueIdentifier,
	@SPECIFICATIONS NvarChar(Max) = NULL,
	@ADDITIONALS    NvarChar(Max) = NULL
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)

		INSERT INTO Memo.ClientMemo(
					ID_CLIENT, DATE, CURRENT_CONTRACT, DISTR, ID_DOC_TYPE, ID_SERVICE, ID_VENDOR, Contract_Id,
					START, FINISH, MONTH_PRICE, PERIOD_PRICE, PERIOD_START, PERIOD_END,
					PERIOD_FULL_PRICE, ID_PAY_TYPE, ID_CONTRACT_PAY_TYPE, FRAMEWORK, DOCUMENTS, LETTER_CANCEL, SYSTEMS)
			OUTPUT inserted.ID INTO @TBL
			SELECT
				@CLIENT, GETDATE(), @CONTRACT, @DISTR, @DOC_TYPE, @SERVICE, @VENDOR, @Contract_Id,
				@START, @FINISH, @MONTH, @PERIOD, @PER_START, @PER_END,
				@PER_FULL, @PAY_TYPE, @ID_CONTRACT_PAY, @FRAMEWORK, @DOCUMENTS, @CANCEL, @SYSTEM

		SELECT @ID = ID
		FROM @TBL

		INSERT INTO Memo.ClientMemoSpecifications
		SELECT @ID, I.Id
		FROM dbo.TableGUIDFromXML(@SPECIFICATIONS) AS I

		INSERT INTO Memo.ClientMemoAdditionals
		SELECT @ID, I.Id
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
GRANT EXECUTE ON [Memo].[CLIENT_MEMO_INSERT] TO rl_client_memo_i;
GO
