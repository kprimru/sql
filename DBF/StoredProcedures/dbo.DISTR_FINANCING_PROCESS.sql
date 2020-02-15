USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:		  Денисов Алексей
Описание:	  
*/

CREATE PROCEDURE [dbo].[DISTR_FINANCING_PROCESS]
	@clientfinancingid INT,
	@distrid INT,
	@netid SMALLINT,
	@techtypeid SMALLINT,
	@systypeid SMALLINT,
	@priceid SMALLINT,
	@discount DECIMAL(8, 4),
	@coef DECIMAL(8, 4),	
	@fixedprice MONEY,
	@periodid SMALLINT,
	@moncount TINYINT,
	@debt BIT = 1,
	@pay SMALLINT = NULL,
	@END	SMALLDATETIME = NULL,
	@BEGIN	SMALLDATETIME = NULL,
	@DF_NAME	NVARCHAR(256) = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @discount IS NULL
		SET @discount = 0

	IF @clientfinancingid IS NULL 
		BEGIN
			--настройки не заданы. Создаем новые по параметрам
			INSERT INTO dbo.DistrFinancingTable(
					DF_ID_DISTR, DF_ID_NET, DF_ID_TECH_TYPE, DF_ID_TYPE, DF_ID_PRICE, DF_DISCOUNT, DF_COEF, 
					DF_FIXED_PRICE, DF_ID_PERIOD, DF_MON_COUNT, DF_DEBT, DF_ID_PAY, DF_END, DF_BEGIN, DF_NAME
					)
			VALUES (
				@distrid, @netid, @techtypeid, @systypeid, @priceid, @discount, @coef, 
				@fixedprice, @periodid, @moncount, @debt, @pay, @END, @BEGIN, @DF_NAME)
    
			SELECT SCOPE_IDENTITY() AS NEW_IDEN
		END
	ELSE
		BEGIN
			--настройки есть, редактируем их
			UPDATE dbo.DistrFinancingTable 
			SET DF_ID_NET = @netid, 
				DF_ID_TECH_TYPE = @techtypeid, 
				DF_ID_TYPE = @systypeid, 
				DF_ID_PRICE = @priceid, 
				DF_DISCOUNT = @discount, 
				DF_COEF = @coef, 
				DF_FIXED_PRICE = @fixedprice, 
				DF_ID_PERIOD = @periodid, 
				DF_MON_COUNT = @moncount,
				DF_DEBT = @debt,
				DF_ID_PAY = @pay,
				DF_END = @END,
				DF_BEGIN = @BEGIN,
				DF_NAME = @DF_NAME
			WHERE DF_ID = @clientfinancingid
		END

	SET NOCOUNT OFF
END
