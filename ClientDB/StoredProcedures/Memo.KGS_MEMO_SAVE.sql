USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Memo].[KGS_MEMO_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@NAME		NVARCHAR(128),
	@DATE		SMALLDATETIME,
	@PRICE		MONEY,
	@MONTH		UNIQUEIDENTIFIER,
	@MON_CNT	SMALLINT,
	@CLIENT		NVARCHAR(MAX),
	@DISTR		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)
	
	IF @ID IS NULL
	BEGIN
		/* новая запись*/
		INSERT INTO Memo.KGSMemo(NAME, DATE, PRICE, ID_MONTH, MON_CNT)
			OUTPUT inserted.ID INTO @TBL
			VALUES(@NAME, @DATE, @PRICE, @MONTH, @MON_CNT)
			
		SELECT @ID = ID
		FROM @TBL
	END
	ELSE
	BEGIN
		/* изменение старой*/
		INSERT INTO Memo.KGSMemo(ID_MASTER, NAME, DATE, PRICE, ID_MONTH, MON_CNT, STATUS, UPD_DATE, UPD_USER)
			OUTPUT inserted.ID INTO @TBL
			SELECT @ID, NAME, DATE, PRICE, ID_MONTH, MON_CNT, 2, UPD_DATE, UPD_USER
			FROM Memo.KGSMemo
			WHERE ID = @ID
			
		DECLARE @OLD_ID UNIQUEIDENTIFIER
		
		SELECT @OLD_ID = ID
		FROM @TBL
		
		UPDATE Memo.KGSMemo
		SET NAME		=	@NAME,
			DATE		=	@DATE,
			PRICE		=	@PRICE,
			ID_MONTH	=	@MONTH,
			MON_CNT		=	@MON_CNT,
			UPD_DATE	=	GETDATE(),
			UPD_USER	=	ORIGINAL_LOGIN()
		WHERE ID = @ID
		
		UPDATE Memo.KGSMemoClient
		SET ID_MEMO = @OLD_ID
		WHERE ID_MEMO = @ID
		
		UPDATE Memo.KGSMemoDistr
		SET ID_MEMO = @OLD_ID
		WHERE ID_MEMO = @ID
	END
	
	DECLARE @cl_xml XML
	
	SET @cl_xml = CAST(@CLIENT AS XML)
	
	INSERT INTO Memo.KGSMemoClient(ID_MEMO, ID_CLIENT, NAME, ADDRESS, NUM)
		SELECT 
			@ID, 
			c.value('(@id)', 'INT'),
			c.value('(name)[1]', 'VARCHAR(500)'),
			c.value('(address)[1]', 'VARCHAR(500)'),
			c.value('(@num)', 'INT')
		FROM @cl_xml.nodes('/root/item') AS a(c)
			
	DECLARE @dis_xml XML
	
	SET @dis_xml = CAST(@DISTR AS XML)
	
	INSERT INTO Memo.KGSMemoDistr(
					ID_MEMO, ID_CLIENT, ID_SYSTEM, DISTR, COMP, ID_NET, ID_TYPE, MON_CNT, 
					PRICE, TAX_PRICE, TOTAL_PRICE, CURVED, TOTAL_PERIOD)
		SELECT 
			@ID,
			c.value('@client', 'INT'),
			c.value('@system', 'INT'),
			c.value('@distr', 'INT'),
			c.value('@comp', 'TINYINT'),
			c.value('@net', 'INT'),
			c.value('@type', 'INT'),
			c.value('@month', 'INT'),
			c.value('@price', 'MONEY'),
			c.value('@tax_price', 'MONEY'),
			c.value('@total_price', 'MONEY'),
			c.value('@curved', 'INT'),
			c.value('@total_period', 'MONEY')
		FROM 
			@dis_xml.nodes('/root/item') AS a(c)
END
