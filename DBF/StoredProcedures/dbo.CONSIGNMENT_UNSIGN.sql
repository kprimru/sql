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

CREATE PROCEDURE [dbo].[CONSIGNMENT_UNSIGN]
	@consid INT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ConsignmentTable
	SET CSG_SIGN = NULL
	WHERE CSG_ID = @consid
END
