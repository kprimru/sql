USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROVISION_REPORT]
WITH EXECUTE AS OWNER
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

		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
			
		CREATE TABLE #result
			(
				[Организация]	NVARCHAR(128),
				[Клиент]		NVARCHAR(128)
			)
				
		DECLARE @SQL NVARCHAR(MAX)
		
		
		DECLARE Y CURSOR LOCAL FOR
			SELECT DISTINCT DATEPART(YEAR, DATE) AS YEAR_NUM
			FROM dbo.Provision
			
		DECLARE @Y INT
		
		OPEN Y
		
		FETCH NEXT FROM Y INTO @Y
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @SQL = 'ALTER TABLE #result ADD [' + CONVERT(NVARCHAR(16), @Y) + '|Выплачено клиенту] MONEY, [' + CONVERT(NVARCHAR(16), @Y) + '|Даты выплат] NVARCHAR(512)'
			--EXEC (@SQL)
			
			SET @SQL = 'ALTER TABLE #result ADD '
			
			SELECT @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_2) + ' - выплачено клиенту] MONEY, [' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_2) + ' - дата выплаты] SMALLDATETIME,'
			FROM 
				(
					SELECT DISTINCT RN_2
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O

			SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)
			
			EXEC (@SQL)
		
			
			SET @SQL = 'ALTER TABLE #result ADD '
			
			SELECT @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_1) + ' - сумма] MONEY, [' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_1) + ' - дата] SMALLDATETIME,'
			FROM 
				(
					SELECT DISTINCT RN_1
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O

			SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)
			
			EXEC (@SQL)
		
			SET @SQL = 'ALTER TABLE #result ADD [' + CONVERT(NVARCHAR(16), @Y) + '|Остаток] MONEY'
			EXEC (@SQL)
		
			FETCH NEXT FROM Y INTO @Y
		END

		CLOSE Y
		DEALLOCATE Y
		
		INSERT INTO #result([Организация], [Клиент])
			SELECT DISTINCT ORG_PSEDO, CL_PSEDO
			FROM dbo.ProvisionView
		
		SET @SQL = '
		UPDATE a
		SET	'
		
		DECLARE Y CURSOR LOCAL FOR
			SELECT DISTINCT DATEPART(YEAR, DATE) AS YEAR_NUM
			FROM dbo.Provision
		
		OPEN Y
		
		FETCH NEXT FROM Y INTO @Y
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @SQL = @SQL + 
				'[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_2) + ' - выплачено клиенту] = 
					(
						SELECT PRICE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE < 0
							AND z.RN_2 = ' + CONVERT(NVARCHAR(16), RN_2) + '
					),		
				[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_2) + ' - дата выплаты] =
					(
						SELECT DATE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE < 0
							AND z.RN_2 = ' + CONVERT(NVARCHAR(16), RN_2) + '
					),'
			FROM 
				(
					SELECT DISTINCT RN_2
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O		
						
			
			SELECT @SQL = @SQL + 
				'[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_1) + ' - сумма] = 
					(
						SELECT PRICE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE > 0
							AND z.RN_1 = ' + CONVERT(NVARCHAR(16), RN_1) + '
					),		
				[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN_1) + ' - дата] =
					(
						SELECT DATE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE > 0
							AND z.RN_1 = ' + CONVERT(NVARCHAR(16), RN_1) + '
					),'
			FROM 
				(
					SELECT DISTINCT RN_1
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O		
		
			SET @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|Остаток] =
					(
						SELECT SUM(PRICE)
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM <= ' + CONVERT(NVARCHAR(16), @Y) + '
					),'
		
			FETCH NEXT FROM Y INTO @Y
		END

		CLOSE Y
		DEALLOCATE Y
		
		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + '
		FROM #result a'
		
		
		PRINT @SQL		
		EXEC (@SQL)
			
		SELECT ROW_NUMBER() OVER(PARTITION BY [Организация] ORDER BY [Организация], [Клиент]) AS [№], *
		FROM #result
		ORDER BY [Организация], [Клиент]
		
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result

		

		/*
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
			
		CREATE TABLE #result
			(
				[Организация]	NVARCHAR(128),
				[Клиент]		NVARCHAR(128)
			)
				
		DECLARE @SQL NVARCHAR(MAX)
		
		
		DECLARE Y CURSOR LOCAL FOR
			SELECT DISTINCT DATEPART(YEAR, DATE) AS YEAR_NUM
			FROM dbo.Provision
			
		DECLARE @Y INT
		
		OPEN Y
		
		FETCH NEXT FROM Y INTO @Y
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = 'ALTER TABLE #result ADD [' + CONVERT(NVARCHAR(16), @Y) + '|Выплачено клиенту] MONEY, [' + CONVERT(NVARCHAR(16), @Y) + '|Даты выплат] NVARCHAR(512)'
			EXEC (@SQL)
		
			
			SET @SQL = 'ALTER TABLE #result ADD '
			
			SELECT @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN) + ' - сумма] MONEY, [' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN) + ' - дата] SMALLDATETIME,'
			FROM 
				(
					SELECT DISTINCT RN
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O

			SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)
			
			EXEC (@SQL)
		
			SET @SQL = 'ALTER TABLE #result ADD [' + CONVERT(NVARCHAR(16), @Y) + '|Остаток] MONEY'
			EXEC (@SQL)
		
			FETCH NEXT FROM Y INTO @Y
		END

		CLOSE Y
		DEALLOCATE Y
		
		INSERT INTO #result([Организация], [Клиент])
			SELECT DISTINCT ORG_PSEDO, CL_PSEDO
			FROM dbo.ProvisionView
		
		SET @SQL = '
		UPDATE a
		SET	'
		
		DECLARE Y CURSOR LOCAL FOR
			SELECT DISTINCT DATEPART(YEAR, DATE) AS YEAR_NUM
			FROM dbo.Provision
		
		OPEN Y
		
		FETCH NEXT FROM Y INTO @Y
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|Выплачено клиенту]  = 
					(
						SELECT SUM(-PRICE)
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE < 0
					), 
					[' + CONVERT(NVARCHAR(16), @Y) + '|Даты выплат] =
					REVERSE(STUFF(REVERSE(
						(
						SELECT CONVERT(NVARCHAR(32), DATE, 104) + '',''
						FROM 
							(
								SELECT DISTINCT DATE
								FROM
									dbo.ProvisionView z
								WHERE z.ORG_PSEDO = a.[Организация]
									AND z.CL_PSEDO = a.[Клиент]
									AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
									AND z.PRICE < 0
							) AS o_O
						ORDER BY DATE DESC FOR XML PATH('''')
					)), 1, 1, '''')),'
						
			
			SELECT @SQL = @SQL + 
				'[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN) + ' - сумма] = 
					(
						SELECT PRICE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE > 0
							AND z.RN = ' + CONVERT(NVARCHAR(16), RN) + '
					),		
				[' + CONVERT(NVARCHAR(16), @Y) + '|' + CONVERT(NVARCHAR(16), RN) + ' - дата] =
					(
						SELECT DATE 
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM = ' + CONVERT(NVARCHAR(16), @Y) + '
							AND z.PRICE > 0
							AND z.RN = ' + CONVERT(NVARCHAR(16), RN) + '
					),'
			FROM 
				(
					SELECT DISTINCT RN
					FROM dbo.ProvisionView
					WHERE YEAR_NUM = @Y
				) AS o_O		
		
			SET @SQL = @SQL + '[' + CONVERT(NVARCHAR(16), @Y) + '|Остаток] =
					(
						SELECT SUM(PRICE)
						FROM dbo.ProvisionView z
						WHERE z.ORG_PSEDO = a.[Организация]
							AND z.CL_PSEDO = a.[Клиент]
							AND z.YEAR_NUM <= ' + CONVERT(NVARCHAR(16), @Y) + '
					),'
		
			FETCH NEXT FROM Y INTO @Y
		END

		CLOSE Y
		DEALLOCATE Y
		
		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + '
		FROM #result a'
		
		
		PRINT @SQL		
		EXEC (@SQL)
			
		SELECT *
		FROM #result
		ORDER BY [Организация], [Клиент]
		
		IF OBJECT_ID('tempdb..#result') IS NOT NULL
			DROP TABLE #result
		*/

		/*
		SELECT 
			ORG_PSEDO, CL_PSEDO, RIC_PRICE, CLIENT_PRICE, RIC_PRICE - CLIENT_PRICE AS PROVISION_DELTA,
			RIC_DATES, CLIENT_DATES
		FROM
			(
				SELECT 
					ORG_PSEDO, CL_PSEDO,
					(
						SELECT SUM(PRICE)
						FROM dbo.Provision b
						WHERE CL_ID = ID_CLIENT
							AND PRICE < 0
							AND ID_ORG = ORG_ID
					) AS RIC_PRICE,
					(
						SELECT SUM(PRICE)
						FROM dbo.Provision b
						WHERE CL_ID = ID_CLIENT
							AND PRICE > 0
							AND ID_ORG = ORG_ID
					) AS CLIENT_PRICE,
					REVERSE(STUFF(REVERSE(
						(
							SELECT CONVERT(NVARCHAR(32), DATE, 104) + ', '
							FROM 
								(
									SELECT DISTINCT DATE
									FROM dbo.Provision
									WHERE
										CL_ID = ID_CLIENT
										AND PRICE < 0
										AND ID_ORG = ORG_ID
								) AS o_O
							ORDER BY DATE DESC FOR XML PATH('')
						)
					), 1, 2, '')) AS RIC_DATES,
					REVERSE(STUFF(REVERSE(
						(
							SELECT CONVERT(NVARCHAR(32), DATE, 104) + ', '
							FROM 
								(
									SELECT DISTINCT DATE
									FROM dbo.Provision
									WHERE
										CL_ID = ID_CLIENT
										AND PRICE > 0
										AND ID_ORG = ORG_ID
								) AS o_O
							ORDER BY DATE DESC FOR XML PATH('')
						)
					), 1, 2, '')) AS CLIENT_DATES
				FROM
					(
						SELECT DISTINCT
							CL_ID, CL_PSEDO, ORG_ID, ORG_PSEDO
						FROM 
							dbo.Provision a
							INNER JOIN dbo.ClientTable b ON a.ID_CLIENT = b.CL_ID
							LEFT OUTER JOIN dbo.OrganizationTable c ON c.ORG_ID = a.ID_ORG
					) AS a
			) AS o_O
		ORDER BY ORG_PSEDO, CL_PSEDO	
		*/
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
