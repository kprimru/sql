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

CREATE PROCEDURE [dbo].[COURIER_CHECK_NAME] 
	@couriername VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT COUR_ID
	FROM dbo.CourierTable
	WHERE COUR_NAME = @couriername

	SET NOCOUNT OFF
END




