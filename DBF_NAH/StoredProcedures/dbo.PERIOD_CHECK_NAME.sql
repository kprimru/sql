USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PERIOD_CHECK_NAME]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[PERIOD_CHECK_NAME]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 15.10.2008
Описание:	  Возвращает ID периода
               с указанным названием.
*/

ALTER PROCEDURE [dbo].[PERIOD_CHECK_NAME]
	@periodname VARCHAR(100)
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

		SELECT PR_ID
		FROM dbo.PeriodTable
		WHERE PR_NAME = @periodname

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PERIOD_CHECK_NAME] TO rl_period_w;
GO
