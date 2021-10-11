USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 25.08.2008
ќписание:	  ¬озвращает 0, если тип финансировани€
               с указанным кодом можно удалить из
               справочника (ни у одного клиента не
               указан этот тип финансировани€),
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
			SET @txt = @txt + 'ƒанный тип финансировани€ указан у одного или нескольких клиентов. ' +
							  '”даление невозможно, пока выбранный тип финансировани€ будет указан хот€ ' +
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
