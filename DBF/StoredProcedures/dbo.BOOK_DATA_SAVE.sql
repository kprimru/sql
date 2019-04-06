USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BOOK_DATA_SAVE]
	@TYPE		NVARCHAR(16),
	@ID			INT,
	@ORG		SMALLINT,
	@INVOICE	INT,
	@AVANS		INT,
	@CODE		NVARCHAR(16),
	@NUM		INT,
	@DATE		SMALLDATETIME,
	@NAME		NVARCHAR(512),
	@INN		NVARCHAR(64),
	@KPP		NVARCHAR(64),
	@IN_NUM		NVARCHAR(16),
	@IN_DATE	SMALLDATETIME,
	@PURCHASE	SMALLDATETIME,
	@TAX		NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
	BEGIN
		IF @TYPE = N'SALE'
			INSERT INTO dbo.BookSale(ID_ORG, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE)
				VALUES(@ORG, @INVOICE, @CODE, @NUM, @DATE, @NAME, @INN, @KPP, @IN_NUM, @IN_DATE)
		ELSE
			INSERT INTO dbo.BookPurchase(ID_ORG, ID_AVANS, ID_INVOICE, CODE, NUM, DATE, NAME, INN, KPP, IN_NUM, IN_DATE, PURCHASE_DATE)
				VALUES (@ORG, @AVANS, @INVOICE, @CODE, @NUM, @DATE, @NAME, @INN, @KPP, @IN_NUM, @IN_DATE, @PURCHASE)
				
		SELECT @ID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		IF @TYPE = N'SALE'
			UPDATE dbo.BookSale
			SET ID_ORG		=	@ORG,
				ID_INVOICE	=	@INVOICE,
				CODE		=	@CODE,
				NUM			=	@NUM,
				DATE		=	@DATE,
				NAME		=	@NAME,
				INN			=	@INN,
				KPP			=	@KPP,
				IN_NUM		=	@IN_NUM,
				IN_DATE		=	@IN_DATE
			WHERE ID = @ID
		ELSE
			UPDATE dbo.BookPurchase
			SET	ID_ORG			=	@ORG,
				ID_AVANS		=	@AVANS,
				ID_INVOICE		=	@INVOICE,
				CODE			=	@CODE,
				NUM				=	@NUM,
				DATE			=	@DATE,
				NAME			=	@NAME,
				INN				=	@INN,
				KPP				=	@KPP,
				IN_NUM			=	@IN_NUM,
				IN_DATE			=	@IN_DATE,
				PURCHASE_DATE	=	@PURCHASE
			WHERE ID = @ID
	END	
	
	IF @TYPE = N'SALE'
		DELETE 
		FROM dbo.BookSaleDetail
		WHERE ID_SALE = @ID
	ELSE
		DELETE 
		FROM dbo.BookPurchaseDetail
		WHERE ID_PURCHASE = @ID
		
	
	DECLARE @XML XML	
	
	SET @XML = CAST(@TAX AS XML)
	
	IF @TYPE = N'SALE'
		INSERT INTO dbo.BookSaleDetail(ID_SALE, ID_TAX, S_BEZ_NDS, S_NDS, S_ALL)
			SELECT 
				@ID, 
				c.value('@tax', 'SMALLINT'),
				c.value('@bez_nds', 'MONEY'),
				c.value('@nds', 'MONEY'),
				c.value('@all', 'MONEY')
			FROM 
				@XML.nodes('/root/item') AS a(c)
	ELSE
		INSERT INTO dbo.BookPurchaseDetail(ID_PURCHASE, ID_TAX, S_BEZ_NDS, S_NDS, S_ALL)
			SELECT 
				@ID, 
				c.value('@tax', 'SMALLINT'),
				c.value('@bez_nds', 'MONEY'),
				c.value('@nds', 'MONEY'),
				c.value('@all', 'MONEY')
			FROM 
				@XML.nodes('/root/item') AS a(c)
END
