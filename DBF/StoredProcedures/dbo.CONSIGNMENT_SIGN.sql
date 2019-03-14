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

CREATE PROCEDURE [dbo].[CONSIGNMENT_SIGN]
	@consid INT,
	@consdate SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_SIGN = @consdate
	WHERE CSG_ID = @consid
END
