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

CREATE PROCEDURE [dbo].[SYSTEM_CHECK_REG_NAME] 
	@systemname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT SYS_ID
	FROM dbo.SystemTable
	WHERE SYS_REG_NAME = @systemname 

	SET NOCOUNT OFF
END






