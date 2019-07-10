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

CREATE PROCEDURE [dbo].[FIELD_GET] 
AS
BEGIN
	SET NOCOUNT ON

	SELECT FL_NAME, FL_WIDTH, FL_CAPTION 
	FROM dbo.FieldTable

	SET NOCOUNT OFF
END



