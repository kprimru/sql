USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[TECHNOL_TYPE_CHECK_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[TECHNOL_TYPE_CHECK_NAME]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 18.12.2008
Описание:	  Возвращает ID технологического
               признака с указанным названием.
*/

ALTER PROCEDURE [dbo].[TECHNOL_TYPE_CHECK_NAME]
	@technoltypename VARCHAR(50)
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

		SELECT TT_ID
		FROM dbo.TechnolTypeTable
		WHERE TT_NAME = @technoltypename

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[TECHNOL_TYPE_CHECK_NAME] TO rl_technol_type_w;
GO
