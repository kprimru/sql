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

CREATE PROCEDURE [dbo].[ACTIVITY_GET] 
	@activityid SMALLINT  
AS
BEGIN
	SET NOCOUNT ON

	SELECT AC_ID, AC_NAME, AC_ACTIVE
	FROM dbo.ActivityTable 
	WHERE AC_ID = @activityid           

	SET NOCOUNT OFF
END







