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

CREATE PROCEDURE [dbo].[ACTIVITY_SELECT]   
  @active BIT = NULL

AS

BEGIN
	SET NOCOUNT ON

	SELECT AC_ID, AC_NAME 
	FROM dbo.ActivityTable 
	WHERE AC_ACTIVE = ISNULL(@active, AC_ACTIVE)
	ORDER BY AC_NAME

	SET NOCOUNT OFF
END






