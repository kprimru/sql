USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_USER_GRAPH_SELECT]
	@COMPLECT	INT,
	@START		SMALLDATETIME,
	@FINISH		SMALLDATETIME,
	@TYPE		NVARCHAR(16)
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

		IF @START IS NULL
			SET @START = DATEADD(MONTH, -3, GETDATE())

		SET @FINISH = DATEADD(DAY, 1, @FINISH)

		SELECT
			UF_DATE,
			CASE @TYPE
				WHEN N'OD' THEN t.UF_OD
				WHEN 'UD' THEN t.UF_UD
				ELSE 0
			END AS USR_COUNT
		FROM USR.USRFile f
		INNER JOIN USR.USRFileTech t ON f.UF_ID = t.UF_ID
		WHERE UF_ID_COMPLECT = @COMPLECT
			AND UF_DATE >= @START
			AND (UF_DATE <= @FINISH OR @FINISH IS NULL)
		ORDER BY UF_DATE DESC

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [USR].[USR_USER_GRAPH_SELECT] TO rl_client_od_ud_graph;
GO