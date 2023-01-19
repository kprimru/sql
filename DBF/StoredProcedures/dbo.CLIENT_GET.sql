USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_GET]  AS SELECT 1')
GO


/*
Автор:         Денисов Алексей
Описание:      Выбор основных данных по всем клиентам,
				либо детальный выбор по указанному клиенту
*/

ALTER PROCEDURE [dbo].[CLIENT_GET]
	@clientid INT
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

		SELECT
				CL_PSEDO, CL_NUM, CL_FULL_NAME, CL_SHORT_NAME, CL_FOUNDING,
				CL_EMAIL, CL_INN, CL_KPP, CL_OKPO, CL_OKONX,
				CL_ACCOUNT,
				BA_ID, BA_NAME,
				AC_ID, AC_NAME,
				FIN_ID, FIN_NAME, 
				ORG_ID, ORG_SHORT_NAME,
				SH_ID, SH_FULL_NAME,
				CLT_ID, CLT_NAME,
				CL_NOTE, CL_NOTE2, CL_PHONE,
				PAYER_ID, PAYER_PSEDO, CL_1C,
				ORGC_ID, ORGC_NAME
		FROM dbo.ClientView
		WHERE CL_ID = @clientid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_GET] TO rl_client_r;
GO
