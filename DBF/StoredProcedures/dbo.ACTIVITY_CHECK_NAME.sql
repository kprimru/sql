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

CREATE PROCEDURE [dbo].[ACTIVITY_CHECK_NAME] 
	@activityname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT AC_ID 
	FROM dbo.ActivityTable 
	WHERE AC_NAME = @activityname

	SET NOCOUNT OFF
END





