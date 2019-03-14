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

CREATE PROCEDURE [dbo].[SYSTEM_NET_CHECK_NAME] 
	@netname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT SN_ID
	FROM dbo.SystemNetTable
	WHERE SN_NAME = @netname 

	SET NOCOUNT OFF
END







