USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SERVICE_STATE_SELECT]
	@SERVICE	INT,
	@DATE		DATETIME = NULL OUTPUT
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

		DECLARE @ID UNIQUEIDENTIFIER

		SELECT @ID = ID, @DATE = DATE
		FROM dbo.ServiceState
		WHERE ID_SERVICE = @SERVICE AND STATUS = 1

		IF OBJECT_ID('tempdb..#t') IS NOT NULL
			DROP TABLE #t

		CREATE TABLE #t
			(
				ID			UNIQUEIDENTIFIER PRIMARY KEY,
				ID_MASTER	UNIQUEIDENTIFIER,
				TP_NAME		NVARCHAR(32),
				TP_ORD		INT,
				TP_NOTE		NVARCHAR(512),
				CNT			INT,
				NOTE		NVARCHAR(MAX)
			)

		INSERT INTO #t(ID, TP_NAME, TP_ORD, TP_NOTE, CNT)
			SELECT NEWID() AS ID, TP_NAME, TP_ORD, TP_NOTE,
				(
					SELECT COUNT(*)
					FROM dbo.ServiceStateDetail z
					WHERE TP = TP_NAME
						AND ID_STATE = @ID
				) AS CNT
			FROM
				(
					SELECT DISTINCT TP
					FROM dbo.ServiceStateDetail
				) AS a
				INNER JOIN dbo.ServiceStateTypeView AS b ON a.TP = b.TP_NAME

		INSERT INTO #t(ID, ID_MASTER, TP_NOTE, NOTE)
			SELECT NEWID(), (SELECT ID FROM #t WHERE TP_NAME = TP), ClientFullName, DETAIL
			FROM
				dbo.ServiceStateDetail
				INNER JOIN dbo.ClientTable ON ClientID = ID_CLIENT
			WHERE ID_STATE = @ID

		SELECT ID, ID_MASTER, TP_NOTE, CASE WHEN CNT IS NOT NULL THEN CONVERT(NVARCHAR(MAX), CNT) ELSE NOTE END AS NOTE, TP_NAME, TP_ORD
		FROM #t
		ORDER BY TP_ORD, TP_NOTE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SERVICE_STATE_SELECT] TO rl_service_state_r;
GO
