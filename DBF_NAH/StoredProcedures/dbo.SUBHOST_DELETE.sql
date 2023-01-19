USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SUBHOST_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SUBHOST_DELETE]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Удалить подхост из справочника
*/

ALTER PROCEDURE [dbo].[SUBHOST_DELETE]
	@subhostid SMALLINT
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
		FROM dbo.SubhostTable
		WHERE SH_ID = @subhostid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[SUBHOST_DELETE] TO rl_subhost_d;
GO
