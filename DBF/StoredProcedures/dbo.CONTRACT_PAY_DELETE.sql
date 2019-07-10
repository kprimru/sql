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

CREATE PROCEDURE [dbo].[CONTRACT_PAY_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.ContractPayTable WHERE COP_ID = @id

	SET NOCOUNT OFF
END