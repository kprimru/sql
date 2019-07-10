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

CREATE PROCEDURE [dbo].[ACTIVITY_ADD] 
	@activityname VARCHAR(100),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.ActivityTable(AC_NAME, AC_ACTIVE, AC_OLD_CODE) 
	VALUES (@activityname, @active, @oldcode)

	IF @returnvalue = 1 
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END