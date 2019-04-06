USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







/*
Автор:			
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[CONSIGNMENT_DETAIL_ADD]
	@csdidcons INT,
	@csdiddistr INT,
	@csdnum SMALLINT,
	@csdcost MONEY,
	@csdprice MONEY,
	@csdtaxprice MONEY,
	@csdtotalprice MONEY,
	@csdpayedprice MONEY,
	@csdcode VARCHAR(50),
	@csdcount SMALLINT,
	@csdname VARCHAR(250),
	@csdunit VARCHAR(100),
	@csdokei VARCHAR(20),
	@csdpacking VARCHAR(50),
	@csdcountinplace VARCHAR(50),
	@csdplace VARCHAR(50),
	@csdmass VARCHAR(50),
	@taxid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ConsignmentDetailTable
		(
			CSD_ID_CONS, CSD_ID_DISTR, CSD_COST, CSD_PRICE, CSD_TAX_PRICE, CSD_TOTAL_PRICE, 
			CSD_PAYED_PRICE, CSD_CODE, CSD_COUNT, CSD_NAME, CSD_UNIT, CSD_OKEI, 
			CSD_PACKING, CSD_COUNT_IN_PLACE, CSD_PLACE, CSD_MASS, CSD_ID_TAX
		)
	VALUES
		(
			@csdidcons, @csdiddistr, @csdcost, @csdprice, @csdtaxprice, @csdtotalprice, 
			@csdpayedprice, @csdcode, @csdcount, @csdname, @csdunit, @csdokei, 
			@csdpacking, @csdcountinplace, @csdplace, @csdmass, @taxid
		)

	SELECT SCOPE_IDENTITY() AS NEW_IDEN
END







