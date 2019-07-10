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

CREATE PROCEDURE [dbo].[REGION_GET] 
	@regionid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RG_ID, RG_NAME, RG_ACTIVE
	FROM dbo.RegionTable 
	WHERE RG_ID = @regionid 

	SET NOCOUNT OFF
END



