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

CREATE PROCEDURE [dbo].[PAY_COEF_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PayCoefTable 
	WHERE PC_ID = @id

	SET NOCOUNT OFF
END
