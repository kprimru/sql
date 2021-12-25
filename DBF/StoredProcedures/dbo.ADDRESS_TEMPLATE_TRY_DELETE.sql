USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей
Описание:
Дата:			16.07.2009
*/
ALTER PROCEDURE [dbo].[ADDRESS_TEMPLATE_TRY_DELETE]
	@atlid TINYINT
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

	/*	IF EXISTS(SELECT * FROM dbo.ClientAddressTable WHERE CA_ID_TEMPLATE = @atlid)
			BEGIN
				SET @res = 1
				SET @txt = @txt + 'Данный шаблон адреса указан в одном или нескольких адресах. ' +
								  'Удаление невозможно, пока выбранный шаблон адреса будет указан хотя ' +
								  'бы в одном адресе.'
			END
	*/
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
GRANT EXECUTE ON [dbo].[ADDRESS_TEMPLATE_TRY_DELETE] TO rl_address_template_d;
GO
