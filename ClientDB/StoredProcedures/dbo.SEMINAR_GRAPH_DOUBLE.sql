USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SEMINAR_GRAPH_DOUBLE]
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		SELECT a.ClientID, ClientFullName, StudentFam, StudentName, StudentOtch, [Сколько раз посещал]
		FROM
			(
				SELECT ClientID, StudentFam, StudentName, StudentOtch, COUNT(*) AS [Сколько раз посещал]
				FROM dbo.ClientSeminarView a WITH(NOEXPAND)
				WHERE StudyDate BETWEEN @BEGIN AND @END
				GROUP BY ClientID, StudentFam, StudentName, StudentOtch
				HAVING COUNT(*) > 1
			) a
			INNER JOIN dbo.ClientView b WITH(NOEXPAND) ON a.ClientID = b.ClientID
		ORDER BY StudentFam, StudentName, StudentOtch

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SEMINAR_GRAPH_DOUBLE] TO rl_seminar_graph;
GO
