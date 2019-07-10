USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей, Богдан Владимир
Дата создания: 27.01.2009
Описание:	  Возвращает 0, если можно удалить 
               налог, 
               -1 в противном случае
*/

CREATE PROCEDURE [dbo].[TAX_TRY_DELETE] 
	@taxid SMALLINT
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''

	-- добавлено 28.04.2009, В.Богдан
	IF EXISTS(SELECT * FROM dbo.PrimaryPayTable WHERE PRP_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + 'Невозможно удалить налог, так как существуют записи о первичной оплате с этим налогом. '
	  END

	IF EXISTS(SELECT * FROM dbo.InvoiceRowTable WHERE INR_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + 'Невозможно удалить налог, так как существуют счет-фактуры с этим налогом. '
	  END

	IF EXISTS(SELECT * FROM dbo.BillDistrTable WHERE BD_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + 'Невозможно удалить налог, так как существуют счета с этим налогом. '
	  END

	IF EXISTS(SELECT * FROM dbo.SaleObjectTable WHERE SO_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + 'Невозможно удалить налог, так как существуют объекты продаж с этим налогом. '
	  END

	IF EXISTS(SELECT * FROM dbo.ActDistrTable WHERE AD_ID_TAX = @taxid)
	  BEGIN
		SET @res = 1
		SET @txt = @txt + CHAR(13) + 'Невозможно удалить налог, так как существуют акты с этим налогом. '
	  END
	--

	SELECT @res AS RES, @txt AS TXT


	SET NOCOUNT OFF

END

