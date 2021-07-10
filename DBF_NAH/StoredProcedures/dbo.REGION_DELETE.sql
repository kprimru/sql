USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Удалить регион с указанным
                кодом из справочника
*/

ALTER PROCEDURE [dbo].[REGION_DELETE]
	@regionid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.RegionTable
	WHERE RG_ID = @regionid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[REGION_DELETE] TO rl_region_d;
GO