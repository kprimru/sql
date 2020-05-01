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

ALTER PROCEDURE [dbo].[TO_GET]
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

		SELECT
			TO_NAME, TO_ID, TO_NUM, TO_REPORT, COUR_ID, TO_VMI_COMMENT, TO_MAIN,
			COUR_NAME, TA_INDEX, TA_HOME, ST_ID, ST_NAME, ST_CITY_NAME, CL_INN, TO_INN, TO_PARENT
		FROM
			dbo.TOView a LEFT OUTER JOIN
			dbo.TOAddressView b ON a.TO_ID = b.TA_ID_TO
		WHERE TO_ID = @toid

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[TO_GET] TO rl_client_r;
GRANT EXECUTE ON [dbo].[TO_GET] TO rl_to_r;
GO