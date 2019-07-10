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

CREATE PROCEDURE [dbo].[CLIENT_TYPE_GET] 
	@id SMALLINT  
AS

BEGIN
	SET NOCOUNT ON

	SELECT CLT_NAME, CLT_ID, CLT_ACTIVE
	FROM dbo.ClientTypeTable 
	WHERE CLT_ID = @id 

	SET NOCOUNT OFF
END
