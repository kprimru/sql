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

ALTER PROCEDURE [dbo].[TO_DISTR_ADD]
	@toid INT,
	@disid VARCHAR(500)
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

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
			(
				DIS_ID INT
			)

		IF @disid IS NOT NULL
			BEGIN
				--парсить строчку и выбирать нужные значения
				INSERT INTO #distr
					SELECT DISTINCT * FROM dbo.GET_TABLE_FROM_LIST(@disid, ',')
			END

		INSERT INTO dbo.TODistrTable(
									TD_ID_TO, TD_ID_DISTR
								)
			SELECT @toid, DIS_ID FROM #distr

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		EXEC [dbo].[TO-Lock@Create (Auto)] @TO_Id = @toid;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[TO_DISTR_ADD] TO rl_client_w;
GRANT EXECUTE ON [dbo].[TO_DISTR_ADD] TO rl_to_distr_w;
GO
