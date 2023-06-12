USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_TYPE_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_TYPE_DELETE]  AS SELECT 1')
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

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DELETE
		FROM dbo.SystemTypeTable
		WHERE SST_ID = @systemtypeid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_DELETE] TO rl_system_type_d;
GO
