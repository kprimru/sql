USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	

/*
�����:			
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[CONSIGNMENT_DETAIL_EDIT]
	@csdid INT,
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

	UPDATE dbo.ConsignmentDetailTable
	SET	CSD_ID_DISTR = @csdiddistr, 
		CSD_COST = @csdcost,
		CSD_PRICE = @csdprice, 
		CSD_TAX_PRICE = @csdtaxprice,
		CSD_TOTAL_PRICE = @csdtotalprice,
		CSD_PAYED_PRICE = @csdpayedprice,
		CSD_CODE = @csdcode, 		
		CSD_COUNT = @csdcount, 
		CSD_NAME = @csdname, 
		CSD_UNIT = @csdunit, 
		CSD_OKEI = @csdokei,
		CSD_PACKING = @csdpacking, 
		CSD_PLACE = @csdplace, 
		CSD_MASS = @csdmass, 
		CSD_ID_TAX = @taxid
	WHERE CSD_ID = @csdid		
END









