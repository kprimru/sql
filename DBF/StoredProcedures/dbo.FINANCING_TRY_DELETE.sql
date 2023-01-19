USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[FINANCING_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[FINANCING_TRY_DELETE]  AS SELECT 1')
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если тип финансирования
               с указанным кодом можно удалить из
               справочника (ни у одного клиента не
               указан этот тип финансирования),
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[FINANCING_TRY_DELETE]
	@financingid SMALLINT
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_FIN = @financingid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данный тип финансирования указан у одного или нескольких клиентов. ' +
							  'Удаление невозможно, пока выбранный тип финансирования будет указан хотя ' +
							  'бы у одного клиента.'
		  END

		SELECT @res AS RES, @txt AS TXT


		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FINANCING_TRY_DELETE] TO rl_financing_d;
GO
