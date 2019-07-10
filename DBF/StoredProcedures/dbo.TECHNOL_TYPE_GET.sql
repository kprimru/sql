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

CREATE PROCEDURE [dbo].[TECHNOL_TYPE_GET] 
	@technoltypeid SMALLINT = NULL
AS

BEGIN
	SET NOCOUNT ON
	
	SELECT TT_ID, TT_NAME, TT_REG, TT_COEF, TT_CALC, TT_ACTIVE
	FROM dbo.TechnolTypeTable  
	WHERE TT_ID = @technoltypeid

	SET NOCOUNT OFF
END







