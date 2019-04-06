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

CREATE PROCEDURE [dbo].[POSITION_GET] 
	@positionid INT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT POS_ID, POS_NAME, POS_ACTIVE 
	FROM dbo.PositionTable 
	WHERE POS_ID = @positionid 

	SET NOCOUNT OFF
END


