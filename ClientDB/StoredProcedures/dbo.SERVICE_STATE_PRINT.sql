USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SERVICE_STATE_PRINT]
	@SERVICE	INT,
	@TP			NVARCHAR(MAX)
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

		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r
			
		CREATE TABLE #r
			(
				ID			UNIQUEIDENTIFIER,
				ID_MASTER	UNIQUEIDENTIFIER,
				TP_NOTE		NVARCHAR(512),
				NOTE		NVARCHAR(MAX),
				TP_NAME		NVARCHAR(32),
				TP_ORD		INT
			)
			
		DECLARE @DT DATETIME
			
		INSERT INTO #r
			EXEC [dbo].[SERVICE_STATE_SELECT] @SERVICE, @DT OUTPUT
			
		DELETE
		FROM #r
		WHERE TP_NAME NOT IN
			(
				SELECT ITEM
				FROM dbo.GET_STRING_TABLE_FROM_LIST(@TP, ',')
			)
			
		DELETE a FROM #r a WHERE ID_MASTER IS NOT NULL AND NOT EXISTS (SELECT * FROM #r b WHERE a.ID_MASTER = b.ID)
			
		ALTER TABLE #r ADD GRP_NAME NVARCHAR(512), GRP_CNT	NVARCHAR(512)
			
		UPDATE a
		SET a.TP_NAME = b.TP_NAME,
			a.TP_ORD = b.TP_ORD,
			GRP_NAME = b.TP_NOTE,
			GRP_CNT = b.NOTE
		FROM 
			#r a
			INNER JOIN #r b ON a.ID_MASTER = b.ID
		WHERE a.TP_NAME IS NULL
			
		DELETE FROM #r WHERE ID_MASTER IS NULL
			
		SELECT /*ID, ID_MASTER, */TP_NOTE, NOTE, @DT AS DT, TP_NAME, GRP_NAME, GRP_CNT
		FROM #r
		ORDER BY TP_ORD, TP_NAME
			
		IF OBJECT_ID('tempdb..#r') IS NOT NULL
			DROP TABLE #r
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
