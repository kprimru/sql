USE [DBF]
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

ALTER PROCEDURE [dbo].[DISTR_AVAILABLE_SELECT]
	@disid INT = NULL
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

		SELECT DIS_ID, DIS_STR, SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE NOT EXISTS
						(
							SELECT * 
							FROM dbo.ClientDistrTable
							WHERE CD_ID_DISTR = DIS_ID
						) AND DIS_ACTIVE = 1

		UNION ALL

		SELECT DIS_ID, DIS_STR, SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM
		FROM dbo.DistrView WITH(NOEXPAND)
		WHERE DIS_ID = @disid
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[DISTR_AVAILABLE_SELECT] TO rl_client_distr_w;
GO