USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	



/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  	
Описание:		
*/

CREATE PROCEDURE [dbo].[SALE_OBJECT_EDIT]
	@soid SMALLINT,
	@soname VARCHAR(50),
	@taxid SMALLINT,
	--@sobill VARCHAR(50),
	--@soinvunit VARCHAR(50),
	--@sookei	VARCHAR(20),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.SaleObjectTable
	SET 
		SO_NAME = @soname, 
		SO_ID_TAX = @taxid, 
		--SO_BILL_STR = @sobill, 
		--SO_INV_UNIT = @soinvunit,
		--SO_OKEI = @sookei,
		SO_ACTIVE = @active
	WHERE SO_ID = @soid
END




