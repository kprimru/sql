USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
Автор:			Денисов Алексей
Описание:		Выбор всех точек обслуживания указанного клиента
*/

ALTER PROCEDURE [dbo].[TO_TRY_DELETE]
	@toid INT
AS
BEGIN
	SET NOCOUNT ON;

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

		IF EXISTS(SELECT * FROM dbo.TODistrTable WHERE TD_ID_TO = @toid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + 'Невозможно удалить ТО, так как ей занесены дистрибутивы.'
		  END

		IF EXISTS(SELECT * FROM dbo.TOTable WHERE TO_ID = @toid AND TO_REPORT = 1)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + 'Невозможно удалить ТО, так как она включена в отчет.'
		  END

		IF EXISTS(SELECT * FROM dbo.TOPersonalTable WHERE TP_ID_TO = @toid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + CHAR(13) + 'Невозможно удалить ТО, так как ей занесены сотрудники.'
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
GRANT EXECUTE ON [dbo].[TO_TRY_DELETE] TO rl_to_d;
GO