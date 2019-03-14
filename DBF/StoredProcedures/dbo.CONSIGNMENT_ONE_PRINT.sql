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

CREATE PROCEDURE [dbo].[CONSIGNMENT_ONE_PRINT]
	@consid INT	
AS
BEGIN
	SET NOCOUNT ON;
	
	EXEC dbo.CONSIGNMENT_PRINT_BY_ID_LIST @consid
END















