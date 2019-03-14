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

CREATE PROCEDURE [dbo].[PLUG_DEL_CONS]
	@consid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_ID_INVOICE = NULL		
	WHERE CSG_ID = @consid
END
