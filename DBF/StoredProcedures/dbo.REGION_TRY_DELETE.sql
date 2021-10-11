USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если регион можно
               удалить из справочника (на него
               не ссылаетс€ ни одна запись
               из населенного пункта),
                -1 в противном случае
*/

ALTER PROCEDURE [dbo].[REGION_TRY_DELETE]
	@regionid SMALLINT
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

		IF EXISTS(SELECT * FROM dbo.CityTable WHERE CT_ID_RG = @regionid)
		BEGIN
			SET @res = 1
			SET @txt = @txt + 'ƒанный регион указан у одного или нескольких населенных пунктов. ' +
							  '”даление невозможно, пока выбранный регион будет указан хот€ ' +
							  'бы у одного населенного пункта.'
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
GRANT EXECUTE ON [dbo].[REGION_TRY_DELETE] TO rl_region_d;
GO
