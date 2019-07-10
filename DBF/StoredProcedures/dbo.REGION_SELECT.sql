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

CREATE PROCEDURE [dbo].[REGION_SELECT]   
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RG_ID, RG_NAME 
	FROM dbo.RegionTable 
	WHERE RG_ACTIVE = ISNULL(@active, RG_ACTIVE)
	ORDER BY RG_NAME

	SET NOCOUNT OFF
END



