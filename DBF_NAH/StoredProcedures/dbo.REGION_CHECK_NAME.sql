USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает ID вида деятельности
               с указанным названием.
*/

ALTER PROCEDURE [dbo].[REGION_CHECK_NAME]
	@regionname VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SELECT RG_ID
	FROM dbo.RegionTable
	WHERE RG_NAME = @regionname

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[REGION_CHECK_NAME] TO rl_region_w;
GO