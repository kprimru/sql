USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_HST_COMMENT_PROCESS]
	@CLIENT	NVARCHAR(MAX)
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

		DECLARE @DATE SMALLDATETIME
		SET @DATE = dbo.MonthOf(GETDATE())

		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				CLIENT	INT,
				NOTE	NVARCHAR(MAX)
			)

		INSERT INTO #temp(CLIENT, NOTE)
			SELECT 
				ClientID, 
				CASE 
					WHEN NOT EXISTS
						(
							SELECT *
							FROM dbo.ClientSearchView z WITH(NOEXPAND)
							WHERE z.ClientID = a.ClientID
								AND z.SearchMonthDate >= DATEADD(MONTH, -2, @DATE)
						) THEN 'Последний поиск за ' + 
							(
								SELECT DATENAME(MONTH, MAX(SearchMonth)) 
								FROM dbo.ClientSearchTable z
								WHERE z.ClientID = a.ClientID
							)
					WHEN EXISTS
						(
							SELECT *
							FROM dbo.ClientSearchView z WITH(NOEXPAND)
							WHERE z.ClientID = a.ClientID
								AND z.SearchMonthDate = DATEADD(MONTH, -2, @DATE)
								AND CNT = 1
						) AND 
						EXISTS
						(
							SELECT *
							FROM dbo.ClientSearchView z WITH(NOEXPAND)
							WHERE z.ClientID = a.ClientID
								AND z.SearchMonthDate = DATEADD(MONTH, -1, @DATE)
								AND CNT = 1
						) THEN 'По одному запросу в месяц'
					WHEN 
						(
							SELECT CNT
							FROM dbo.ClientSearchView z WITH(NOEXPAND)
							WHERE z.ClientID = a.ClientID
								AND z.SearchMonthDate = DATEADD(MONTH, -1, @DATE)					
						) < 8 THEN 'Обратить внимание на историю поисков'
					ELSE ''
				END AS COMMENT
			FROM		
				(
					SELECT DISTINCT Item AS ClientID
					FROM dbo.GET_TABLE_FROM_LIST(@CLIENT, ',')
				) AS a
		
		DELETE FROM #temp WHERE NOTE = '' OR NOTE IS NULL
		
		DECLARE CLIENT CURSOR LOCAL FOR
			SELECT CLIENT, NOTE FROM #temp
			
		OPEN CLIENT
		
		DECLARE @XML XML
		DECLARE @XML2 XML
		DECLARE @CL_ID INT
		DECLARE @NOTE NVARCHAR(MAX)
		
		FETCH NEXT FROM CLIENT INTO @CL_ID, @NOTE
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @XML = CSC_COMMENTS
			FROM dbo.ClientSearchComments
			WHERE CSC_ID_CLIENT = @CL_ID
		
			SET @XML2 =
				(
					SELECT CM_TEXT AS '@TEXT', CONVERT(NVARCHAR(32), CM_DATE, 121) AS '@DATE'
					FROM
						(
							SELECT CM_TEXT, CONVERT(DATETIME, CM_DATE, 121) AS CM_DATE
							FROM	
								(
									SELECT 
										z.value('@TEXT[1]', 'VARCHAR(250)') AS CM_TEXT, 
										z.value('@DATE[1]', 'VARCHAR(50)') AS CM_DATE
									FROM @XML.nodes('/ROOT/COMMENT') x(z)
								) AS o_O
								
							UNION ALL
							
							SELECT @NOTE, GETDATE()
						) AS o_O
					ORDER BY CM_DATE DESC FOR XML PATH('COMMENT'), ROOT('ROOT')
				)
		
			UPDATE dbo.ClientSearchComments
			SET CSC_COMMENTS = @XML2
			WHERE CSC_ID_CLIENT = @CL_ID
			
			IF @@ROWCOUNT = 0
				INSERT INTO dbo.ClientSearchComments(CSC_ID_CLIENT, CSC_COMMENTS)
					SELECT @CL_ID, @XML2
		
			FETCH NEXT FROM CLIENT INTO @CLIENT, @NOTE
		END
		
		CLOSE CLIENT
		DEALLOCATE CLIENT
		
		SELECT *
		FROM #temp
		
		IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			DROP TABLE #temp
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
