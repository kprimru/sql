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

CREATE PROCEDURE [dbo].[UNIT_GET] 
	@unitid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT UN_ID, UN_NAME, UN_OKEI, UN_ACTIVE
	FROM dbo.UnitTable  
	WHERE UN_ID = @unitid

	SET NOCOUNT OFF
END









