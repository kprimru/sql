USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Stat].[STAT_SLICE_SAVE]
	@DATE	SMALLDATETIME,
	@TP		TINYINT = 1
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @LAST_SLICE SMALLDATETIME

		SELECT @LAST_SLICE = DATE
		FROM Stat.Slice
		WHERE TP = @TP
			AND STATUS = 1

		IF OBJECT_ID('tempdb..#stat') IS NOT NULL
			DROP TABLE #stat

		CREATE TABLE #stat
			(
				ID		UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWSEQUENTIALID(),
				GR		NVARCHAR(256),
				NAME	NVARCHAR(256),
				CNT		INT
			)

		IF @TP = 1
		BEGIN
			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Состояние работы', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, COUNT(*) AS CNT
						FROM
							Client.WorkState b
							LEFT OUTER JOIN Client.Company a ON a.ID_WORK_STATE = b.ID AND STATUS = 1
						GROUP BY GR
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Категория', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, COUNT(*) AS CNT
						FROM
							Client.PayCategory b
							LEFT OUTER JOIN Client.Company a ON a.ID_PAY_CAT = b.ID AND STATUS = 1
						GROUP BY GR
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Потенциал', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, COUNT(*) AS CNT
						FROM
							Client.Potential b
							LEFT OUTER JOIN Client.Company a ON a.ID_POTENTIAL = b.ID AND STATUS = 1
						GROUP BY GR
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Перспективность', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, COUNT(*) AS CNT
						FROM
							Client.Availability b
							LEFT OUTER JOIN Client.Company a ON a.ID_AVAILABILITY = b.ID AND STATUS = 1
						GROUP BY GR
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Наличие карты', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, COUNT(*) AS CNT
						FROM
							(
									SELECT DISTINCT
										CARD,
										CASE CARD
											WHEN 1 THEN 'неизвестно'
											WHEN 2 THEN 'нет'
											WHEN 3 THEN 'да'
										END AS GR,
										CASE CARD
											WHEN 1 THEN 30
											WHEN 2 THEN 20
											WHEN 3 THEN 10
										END AS ORD
									FROM Client.Company
									WHERE STATUS = 1 AND CARD IS NOT NULL
								) AS b
							LEFT OUTER JOIN Client.Company a ON a.CARD = b.CARD AND STATUS = 1
						GROUP BY GR
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Конкурент', GR, CNT
				FROM
					(
						SELECT GR, MIN(ORD) AS ORD, SUM(CASE WHEN d.ID IS NULL THEN 0 ELSE 1 END) AS CNT
						FROM
							Client.RivalSystem c
							LEFT OUTER JOIN Client.CompanyRival b ON b.ID_RIVAL = c.ID AND b.STATUS = 1 AND b.ACTIVE = 1
							LEFT OUTER JOIN Client.Company a ON b.ID_COMPANY = a.ID AND a.STATUS = 1
							LEFT OUTER JOIN Client.CompanyRivalView d ON d.ID = b.ID
						GROUP BY GR
					) AS o_O
				ORDER BY ORD
		END
		ELSE
		BEGIN
			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Получено', GR, CNT
				FROM
					(
						SELECT 'С визитом' AS GR, 1 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE
							AND EXISTS
								(
									SELECT *
									FROM Meeting.AssignedMeeting z
									WHERE z.ID_COMPANY = a.ID_COMPANY
										AND z.STATUS = 1
										AND z.BDATE_S >= @LAST_SLICE
								)

						UNION ALL

						SELECT 'Без визита' AS GR, 2 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
							INNER JOIN Client.Availability c ON c.ID = b.ID_AVAILABILITY
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE
							AND b.STATUS = 1
							AND c.NAME = 'ПЕРСПЕКТИВНЫЕ'
							AND NOT EXISTS
								(
									SELECT *
									FROM Meeting.AssignedMeeting z
									WHERE z.ID_COMPANY = a.ID_COMPANY
										AND z.STATUS = 1
										AND z.BDATE_S >= @LAST_SLICE
								)
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Сдано', GR, CNT
				FROM
					(
						SELECT 'Продажа' AS GR, 1 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
							INNER JOIN Client.Availability c ON c.ID = b.ID_AVAILABILITY
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE AND RETURN_DATE IS NOT NULL
							AND b.STATUS = 1
							AND c.NAME = 'КЛИЕНТЫ'
							AND
								(
									SELECT TOP 1 y.NAME
									FROM
										Client.Company z
										INNER JOIN Client.Availability y ON y.ID = z.ID_AVAILABILITY
									WHERE z.ID_MASTER = b.ID
										AND STATUS = 2
										AND EDATE <= @LAST_SLICE
									ORDER BY EDATE DESC
								) <> 'КЛИЕНТЫ'


						UNION ALL

						SELECT 'Перспективные' AS GR, 2 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
							INNER JOIN Client.Availability c ON c.ID = b.ID_AVAILABILITY
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE AND RETURN_DATE IS NOT NULL
							AND b.STATUS = 1
							AND c.NAME = 'ПЕРСПЕКТИВНЫЕ'

						UNION ALL

						SELECT 'Неперспективные' AS GR, 3 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
							INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
							INNER JOIN Client.Availability c ON c.ID = b.ID_AVAILABILITY
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE AND RETURN_DATE IS NOT NULL
							AND b.STATUS = 1
							AND c.NAME = 'НЕПЕРСПЕКТИВНЫЕ'
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'В наличии', GR, CNT
				FROM
					(
						SELECT '' AS GR, 1 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Из них', GR, CNT
				FROM
					(
						SELECT 'Без звонка' AS GR, 1 AS ORD, COUNT(*) AS CNT
						FROM
							Client.CompanyProcess a
						WHERE PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE
							AND NOT EXISTS
								(
									SELECT *
									FROM Client.Call z
									WHERE z.STATUS = 1
										AND z.ID_COMPANY = a.ID_COMPANY
								)

						UNION ALL

						SELECT c.NAME AS GR, MIN(ORD), COUNT(*)
						FROM
							Client.CompanyProcess a
							INNER JOIN Client.CompanyRival b ON a.ID_COMPANY = b.ID_COMPANY
							INNER JOIN Client.RivalSystem c ON c.ID = b.ID_RIVAL
							INNER JOIN Client.CompanyRivalView d ON d.ID = b.ID
						WHERE b.STATUS = 1 AND /*b.ACTIVE = 1 AND */c.NAME IN ('ГАРАНТ', 'БСС')
							AND PROCESS_TYPE = N'SALE' AND ASSIGN_DATE >= @LAST_SLICE
						GROUP BY c.NAME
					) AS o_O
				ORDER BY ORD

			INSERT INTO #stat(GR, NAME, CNT)
				SELECT 'Встреч', GR, CNT
				FROM
					(
						SELECT 'Всего' AS GR, 1 AS ORD, COUNT(*) AS CNT
						FROM
							Meeting.ClientMeeting a
						WHERE a.DATE >= @LAST_SLICE
							AND STATUS = 1

						UNION ALL

						SELECT d.NAME, MIN(ORD), COUNT(*) AS CNT
						FROM
							Meeting.ClientMeeting a
							INNER JOIN Meeting.AssignedMeeting b ON a.ID_ASSIGNED = b.ID
							INNER JOIN Client.CompanyRival c ON b.ID_COMPANY = c.ID_COMPANY
							INNER JOIN Client.RivalSystem d ON d.ID = c.ID_RIVAL
							INNER JOIN Client.CompanyRivalView e ON e.ID = c.ID
						WHERE a.DATE >= @LAST_SLICE
							AND a.STATUS = 1 AND b.STATUS = 1 AND d.NAME IN ('ГАРАНТ', 'БСС')
						GROUP BY d.NAME
					) AS o_O
				ORDER BY ORD
		END

		DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

		INSERT INTO Stat.Slice(DATE, CNT, TP)
			OUTPUT inserted.ID INTO @TBL
			SELECT @DATE, (SELECT COUNT(*) FROM Client.Company WHERE STATUS = 1), @TP

		DECLARE @SLICE UNIQUEIDENTIFIER

		SELECT @SLICE = ID
		FROM @TBL

		INSERT INTO Stat.SliceDetail(ID_SLICE, GRP, DTL_NAME, DTL_COUNT)
			SELECT @SLICE, GR, NAME, CNT
			FROM #stat

		IF OBJECT_ID('tempdb..#stat') IS NOT NULL
			DROP TABLE #stat
	END TRY
	BEGIN CATCH
		DECLARE	@SEV	INT
		DECLARE	@STATE	INT
		DECLARE	@NUM	INT
		DECLARE	@PROC	NVARCHAR(128)
		DECLARE	@MSG	NVARCHAR(2048)

		SELECT
			@SEV	=	ERROR_SEVERITY(),
			@STATE	=	ERROR_STATE(),
			@NUM	=	ERROR_NUMBER(),
			@PROC	=	ERROR_PROCEDURE(),
			@MSG	=	ERROR_MESSAGE()

		EXEC Security.ERROR_RAISE @SEV, @STATE, @NUM, @PROC, @MSG
	END CATCH
END
GO
GRANT EXECUTE ON [Stat].[STAT_SLICE_SAVE] TO rl_stat_w;
GO