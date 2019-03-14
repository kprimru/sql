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

CREATE PROCEDURE [dbo].[DOC_SALE_OBJECT_DEF_ADD]
	@soid SMALLINT,
	@docid SMALLINT,
	@goodid SMALLINT,
	@unitid SMALLINT,
	@print BIT,
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.DocumentSaleObjectDefaultTable
			(
				DSD_ID_SO, DSD_ID_DOC, DSD_ID_GOOD, DSD_ID_UNIT, DSD_PRINT, DSD_ACTIVE
			)
	VALUES (
				@soid, @docid, @goodid, @unitid, @print, @active
			)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END





