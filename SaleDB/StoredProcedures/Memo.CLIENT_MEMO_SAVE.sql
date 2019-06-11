USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[CLIENT_MEMO_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@CLIENT		UNIQUEIDENTIFIER,
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
	@ID_CONTRACT_PAY	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER)
		
		INSERT INTO Memo.ClientMemo(
					ID_CLIENT, DATE, ID_DOC_TYPE, ID_SERVICE, ID_VENDOR, 
					START, FINISH, MONTH_PRICE, PERIOD_PRICE, PERIOD_START, PERIOD_FINISH, 
					PERIOD_FULL_PRICE, ID_PAY_TYPE, ID_CONTRACT_PAY, FRAMEWORK, DOCUMENTS, LETTER_CANCEL, SYSTEMS)
			OUTPUT inserted.ID INTO @TBL
			SELECT 
				@CLIENT, GETDATE(), @DOC_TYPE, @SERVICE, @VENDOR, 
				@START, @FINISH, @MONTH, @PERIOD, @PER_START, @PER_END, 
				@PER_FULL, @PAY_TYPE, @ID_CONTRACT_PAY, @FRAMEWORK, @DOCUMENTS, @CANCEL, @SYSTEM
				
		SELECT @ID = ID
		FROM @TBL
	END
	ELSE
	BEGIN
		UPDATE Memo.ClientMemo
		SET	ID_DOC_TYPE			=	@DOC_TYPE,
			ID_SERVICE			=	@SERVICE,
			ID_VENDOR			=	@VENDOR,
			START				=	@START,
			FINISH				=	@FINISH,
			MONTH_PRICE			=	@MONTH,
			PERIOD_PRICE		=	@PERIOD,
			PERIOD_START		=	@PER_START,
			PERIOD_FINISH		=	@PER_END,
			PERIOD_FULL_PRICE	=	@PER_FULL,
			ID_PAY_TYPE			=	@PAY_TYPE,
			ID_CONTRACT_PAY		= @ID_CONTRACT_PAY,
			FRAMEWORK			=	@FRAMEWORK,
			DOCUMENTS			=	@DOCUMENTS,
			LETTER_CANCEL		=	@CANCEL,
			SYSTEMS				=	@SYSTEM
		WHERE ID = @ID
		
		DELETE FROM Memo.ClientMemoConditions
		WHERE ID_MEMO = @ID
	END
END
