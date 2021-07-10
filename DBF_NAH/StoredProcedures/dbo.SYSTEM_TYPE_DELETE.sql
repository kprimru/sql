USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Удалить технологический признак
               с указанным кодом из справочника
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_DELETE]
	@systemtypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.SystemTypeTable
	WHERE SST_ID = @systemtypeid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_DELETE] TO rl_system_type_d;
GO