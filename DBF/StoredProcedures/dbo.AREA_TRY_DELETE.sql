USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[AREA_TRY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[AREA_TRY_DELETE]  AS SELECT 1')
GO


/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[AREA_TRY_DELETE]
	@areaid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_AREA = @areaid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данный район указан у одного или нескольких городов. ' +
								  'Удаление невозможно, пока выбранный район будет указан хотя ' +
								  'бы у одного города.'
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
GRANT EXECUTE ON [dbo].[AREA_TRY_DELETE] TO rl_area_d;
GO
