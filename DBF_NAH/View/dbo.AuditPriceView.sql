USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[AuditPriceView]
AS
SELECT 'Система "' + SYS_SHORT_NAME + '" отсутствует в прейскуранте' AS ER_MSG
FROM dbo.SystemTable a
WHERE
	NOT EXISTS
		(
			SELECT *
			FROM dbo.PriceSystemTable
			WHERE PS_ID_SYSTEM = a.SYS_ID AND
				PS_ID_PERIOD =
					(
						SELECT PR_ID
						FROM dbo.PeriodTable
						WHERE GETDATE() >= PR_DATE AND GETDATE() <  DATEADD(DAY, 1, PR_END_DATE)
					)
		) AND a.SYS_ACTIVE = 1

UNION ALL

SELECT 'Отсутствует прейскурант на следующий месяц' AS ER_MSG
WHERE NOT EXISTS
	(
		SELECT *
		FROM dbo.PriceSystemTable
		WHERE PS_ID_PERIOD = 
			(
				SELECT PR_ID
				FROM dbo.PeriodTable
				WHERE PR_DATE = DATEADD(MONTH, 1,
					(
						SELECT PR_DATE
						FROM dbo.PeriodTable
						WHERE PR_DATE < GETDATE()
							AND DATEADD(DAY, 1, PR_END_DATE) > GETDATE()
					))
			)
	)

UNION ALL

SELECT 'Отсутствует прейскурант на текущий месяц' AS ER_MSG
WHERE NOT EXISTS
	(
		SELECT *
		FROM dbo.PriceSystemTable
		WHERE PS_ID_PERIOD = 
			(
				SELECT PR_ID
				FROM dbo.PeriodTable
				WHERE PR_DATE =
					(
						SELECT PR_DATE
						FROM dbo.PeriodTable
						WHERE PR_DATE < GETDATE()
							AND DATEADD(DAY, 1, PR_END_DATE) > GETDATE()
					)
			)
	)
GO
