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

CREATE PROCEDURE [dbo].[SYSTEM_NET_DELETE] 
	@systemnetid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.SystemNetTable 
	WHERE SN_ID = @systemnetid

	SET NOCOUNT OFF
END



