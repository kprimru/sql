USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Дата создания: 25.08.2008
Описание:	  Возвращает 0, если указанную 
               отчетную должность можно удалить 
               (должность не указана ни у одного 
                сотрудника), -1 в противном случае
*/

ALTER PROCEDURE [dbo].[REPORT_POSITION_TRY_DELETE] 
	@positionreportid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.ClientPersonalTable WHERE PER_ID_REPORT_POS = @positionreportid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данная отчетная должность указана у одного или нескольких сотрудников клиента. ' + 
							  'Удаление невозможно, пока выбранная отчетная должность будет указан хотя ' +
							  'бы у одного сотрудника.'
		  END

		-- добавлено 29.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.TOPersonalTable WHERE TP_ID_RP = @positionreportid)
		  BEGIN
			SET @res = 1
			SET @txt = @txt + 'Данная отчетная должность указана у одного или нескольких сотрудников ТО. ' + 
							  'Удаление невозможно, пока выбранная отчетная должность будет указан хотя ' +
							  'бы у одного сотрудника.'
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
GRANT EXECUTE ON [dbo].[REPORT_POSITION_TRY_DELETE] TO rl_report_position_d;
GO