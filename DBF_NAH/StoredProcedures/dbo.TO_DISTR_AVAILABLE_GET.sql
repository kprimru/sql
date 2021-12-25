USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/

ALTER PROCEDURE [dbo].[TO_DISTR_AVAILABLE_GET]
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

		SELECT DIS_STR, DIS_ID
		FROM dbo.ClientDistrView
		WHERE
				CD_ID_CLIENT =
						(
							SELECT TO_ID_CLIENT
							FROM dbo.TOTable
							WHERE TO_ID = @toid
						) AND
				NOT EXISTS
						(
							SELECT *
							FROM dbo.TODistrView
							WHERE CD_ID_CLIENT = TO_ID_CLIENT AND
									CD_ID_DISTR = TD_ID_DISTR
						)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_DISTR_AVAILABLE_GET] TO rl_to_distr_r;
GO
