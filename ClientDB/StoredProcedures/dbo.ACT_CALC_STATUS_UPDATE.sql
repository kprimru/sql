USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_CALC_STATUS_UPDATE]
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

		DECLARE @TBL TABLE (ID UNIQUEIDENTIFIER, OLD_STATUS NVARCHAR(128), NEW_STATUS NVARCHAR(128))

		INSERT INTO @TBL (ID, OLD_STATUS)
			SELECT ID, ISNULL(CALC_STATUS, 'Не расчитан')
			FROM dbo.ActCalc a
			WHERE STATUS = 1
				AND (CALC_STATUS <> 'Расчитан полностью' OR CALC_STATUS IS NULL)

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		CREATE TABLE #act
			(
				SYS_REG_NAME	NVARCHAR(32),
				DIS_NUM			INT,
				DIS_COMP_NUM	TINYINT,
				PR_DATE			SMALLDATETIME
			)

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = 'CREATE UNIQUE CLUSTERED INDEX [IX_' + CONVERT(NVARCHAR(64), NEWID()) + '] ON #act (DIS_NUM, SYS_REG_NAME, PR_DATE, DIS_COMP_NUM)'
		EXEC (@SQL)

		INSERT INTO #act(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE)
			SELECT DISTINCT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM, PR_DATE
			FROM dbo.DBFActView c WITH(NOLOCK)
			WHERE PR_DATE >= DATEADD(YEAR, -2, GETDATE())

		--ToDo переписать это убожество
		UPDATE z
		SET NEW_STATUS =
			CASE
				WHEN NOT EXISTS
					(
						SELECT *
						FROM
							dbo.ActCalcDetail b
							INNER JOIN dbo.SystemTable p ON b.SYS_REG = p.SystemBaseName
							INNER JOIN dbo.SystemTable q ON p.HostID = q.HostID
							INNER JOIN #act c ON q.SystemBaseName = c.SYS_REG_NAME AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM AND MON = PR_DATE
						WHERE a.ID = b.ID_MASTER
					) THEN 'Не расчитан'
				WHEN NOT EXISTS
					(
						SELECT *
						FROM dbo.ActCalcDetail b
						WHERE a.ID = b.ID_MASTER
							AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.SystemTable p
										INNER JOIN dbo.SystemTable q ON p.HostID = q.HostID
										INNER JOIN #act c ON q.SystemBaseName = c.SYS_REG_NAME
									WHERE DISTR = DIS_NUM
										AND COMP = DIS_COMP_NUM
										AND MON = PR_DATE
										AND b.SYS_REG = p.SystemBaseName
								)
					) THEN 'Расчитан полностью'
				WHEN EXISTS
					(
						SELECT *
						FROM
							dbo.ActCalcDetail b
							INNER JOIN dbo.SystemTable p ON b.SYS_REG = p.SystemBaseName
							INNER JOIN dbo.SystemTable q ON p.HostID = q.HostID
							INNER JOIN #act c ON q.SystemBaseName = c.SYS_REG_NAME AND DISTR = DIS_NUM AND COMP = DIS_COMP_NUM AND MON = PR_DATE
						WHERE a.ID = b.ID_MASTER
					) AND EXISTS
					(
						SELECT *
						FROM dbo.ActCalcDetail b
						WHERE a.ID = b.ID_MASTER
							AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.SystemTable p
										INNER JOIN dbo.SystemTable q ON p.HostID = q.HostID
										INNER JOIN #act c ON q.SystemBaseName = c.SYS_REG_NAME
									WHERE DISTR = DIS_NUM
										AND COMP = DIS_COMP_NUM
										AND MON = PR_DATE
										AND b.SYS_REG = p.SystemBaseName
								)
					) AND EXISTS
					(
						SELECT *
						FROM
							dbo.ActCalcDetail b
							INNER JOIN dbo.DBFBillView c ON b.SYS_REG = SYS_REG_NAME
													AND DISTR = DIS_NUM
													AND COMP = DIS_COMP_NUM
													AND MON = PR_DATE
						WHERE a.ID = b.ID_MASTER
							AND NOT EXISTS
								(
									SELECT *
									FROM
										dbo.SystemTable p
										INNER JOIN dbo.SystemTable q ON p.HostID = q.HostID
										INNER JOIN #act t ON q.SystemBaseName = t.SYS_REG_NAME
									WHERE DISTR = DIS_NUM
										AND COMP = DIS_COMP_NUM
										AND MON = PR_DATE
										AND b.SYS_REG = p.SystemBaseName
								)
					)
					THEN 'Расчитан частично'
				ELSE 'ХЗ'
			END
		FROM
			dbo.ActCalc a
			INNER JOIN @TBL z ON a.ID = z.ID

		UPDATE @TBL
		SET NEW_STATUS = 'Расчитан частично'
		WHERE NEW_STATUS = 'ХЗ'

		UPDATE a
		SET CALC_STATUS = z.NEW_STATUS
		FROM
			dbo.ActCalc a
			INNER JOIN @TBL z ON a.ID = z.ID
		WHERE OLD_STATUS <> NEW_STATUS

		IF OBJECT_ID('tempdb..#act') IS NOT NULL
			DROP TABLE #act

		--EXEC dbo.CLIENT_MESSAGE_SEND NULL, 1, 'boss',  @MSG, 0

		INSERT INTO dbo.ClientMessage(TP, DATE, NOTE, RECEIVE_USER, HARD_READ)
			SELECT 1, GETDATE(), 'Изменен статус расчета "' + USR + ' (' + SERVICE + ') с ' + OLD_STATUS + ' на ' + NEW_STATUS, USR, 0
			FROM
				dbo.ActCalc a
				INNER JOIN @TBL z ON a.ID = z.ID
			WHERE OLD_STATUS <> NEW_STATUS

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
