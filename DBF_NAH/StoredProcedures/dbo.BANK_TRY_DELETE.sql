USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[BANK_TRY_DELETE]
	@bankid INT
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

		IF EXISTS(SELECT * FROM dbo.ClientTable WHERE CL_ID_BANK = @bankid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данный банк указан у одного или нескольких клиентов. ' +
								  'Удаление невозможно, пока выбранный банк будет указан хотя ' +
								  'бы у одного клиента.' + CHAR(13)
			END

		-- добавлено 30.04.2009, В.Богдан
		IF EXISTS(SELECT * FROM dbo.OrganizationTable WHERE ORG_ID_BANK = @bankid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данный банк указан у одной или нескольких обслуживающих организаций. ' +
								  'Удаление невозможно, пока выбранный банк будет указан хотя ' +
								  'бы у одной обслуживающей организации.' + CHAR(13)
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
GRANT EXECUTE ON [dbo].[BANK_TRY_DELETE] TO rl_bank_d;
GO
