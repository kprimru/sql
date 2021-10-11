USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если тип системы
               можно удалить,
               -1 в противном случае
*/

ALTER PROCEDURE [dbo].[SYSTEM_TYPE_TRY_DELETE]
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

		DECLARE @res INT
		DECLARE @txt VARCHAR(MAX)

		SET @res = 0
		SET @txt = ''

		-- добавлено 28.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.RegNodeFullTable WHERE RN_ID_TYPE = @systemtypeid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Невозможно удалить тип системы, так как с ним был зарегистрирован дистрибутив.'
		  END
		IF EXISTS(SELECT * FROM dbo.ClientSystemHistoryTable WHERE CSH_ID_TYPE = @systemtypeid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип системы, так как '
								+ 'имеются записи в истории систем клиента с данным типом.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PeriodRegTable WHERE REG_ID_TYPE = @systemtypeid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип системы, так как '
								+ 'имеются записи в истории рег.узла с данным типом.' + CHAR(13)
			END
		IF EXISTS(SELECT * FROM dbo.PeriodRegNewTable WHERE RNN_ID_TECH_TYPE = @systemtypeid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Невозможно удалить тип системы, так как '
						+ 'имеются записи о регистрации новых систем с данным типом.'
			END
		--

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
GRANT EXECUTE ON [dbo].[SYSTEM_TYPE_TRY_DELETE] TO rl_system_type_d;
GO
