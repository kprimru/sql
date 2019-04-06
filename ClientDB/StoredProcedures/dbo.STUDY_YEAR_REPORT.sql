USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[STUDY_YEAR_REPORT]
	@STATUS		INT = NULL,
	@MANAGER	INT = NULL,
	@SERVICE	INT = NULL,
	@DATE		SMALLDATETIME = NULL,
	@TYPE		VARCHAR(MAX) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @TBL TABLE (STUDY_YEAR INT)

	INSERT INTO @TBL(STUDY_YEAR)
		SELECT DISTINCT DATEPART(YEAR, DATE)
		FROM dbo.ClientStudy
		WHERE STATUS = 1

	DECLARE @SQL NVARCHAR(MAX)

	SET @SQL = N'
		SELECT 
			ClientFullName AS [������], ServiceName AS [��], ManagerName AS [���-��], CATEGORY AS [���������], ConnectDate AS [���������], '

	SELECT @SQL = @SQL + 'Teach' + CONVERT(VARCHAR(20), STUDY_YEAR) + ' AS [' + CONVERT(VARCHAR(20), STUDY_YEAR) + '], '
	FROM @TBL
	ORDER BY STUDY_YEAR

	DECLARE @YEAR_COUNT INT
	DECLARE @CUR_YEAR INT

	SET @SQL = @SQL + '
		CASE
			WHEN '
	SELECT @SQL = @SQL + 'Teach' + CONVERT(VARCHAR(20), STUDY_YEAR) + ' = 0 AND '
	FROM @TBL
	ORDER BY STUDY_YEAR

	SET @SQL = LEFT(@SQL, LEN(@SQL) - 4) + ' THEN ''�� ��������'''

	SELECT @CUR_YEAR = MIN(STUDY_YEAR)
	FROM @TBL

	WHILE @CUR_YEAR IS NOT NULL
	BEGIN
		SET @SQL = @SQL + '
			WHEN Teach' + CONVERT(VARCHAR(20), @CUR_YEAR) + ' <> 0 '

		SELECT @SQL = @SQL + 'AND Teach' + CONVERT(VARCHAR(20), STUDY_YEAR) + ' = 0 '
		FROM @TBL
		WHERE STUDY_YEAR > @CUR_YEAR
		ORDER BY STUDY_YEAR

		SET @SQL = @SQL + 'THEN ''�������� � ' + CONVERT(VARCHAR(20), @CUR_YEAR) + ''''

		SET @CUR_YEAR = 
			(
				SELECT MIN(STUDY_YEAR)
				FROM @TBL
				WHERE STUDY_YEAR > @CUR_YEAR
			)
	END

	SET @SQL = @SQL + '
		END AS [�������]'

	SET @SQL = @SQL + '
		FROM
			(
				SELECT 
					ClientFullName, ServiceName, ManagerName, CATEGORY, '

	SELECT @SQL = @SQL + '
					(
						SELECT COUNT(*)
						FROM dbo.ClientStudy d
						WHERE d.ID_CLIENT = a.ClientID
							AND d.ID_PLACE NOT IN (3, 5)
							AND ISNULL(Teached, 1) = 1
							AND STATUS = 1
							AND DATEPART(YEAR, DATE) = ' + CONVERT(VARCHAR(20), STUDY_YEAR) + '
					) AS Teach' + CONVERT(VARCHAR(20), STUDY_YEAR) + ','
	FROM @TBL
	ORDER BY STUDY_YEAR

	SET @SQL = LEFT(@SQL, LEN(@SQL) - 1) + ',
					(
						SELECT DATE
						FROM dbo.ClientStudyConnectView z 
						WHERE z.ClientID = a.ClientID
					) AS ConnectDate
				FROM 
					dbo.ClientView a WITH(NOEXPAND)
					LEFT OUTER JOIN dbo.ClientTypeAllView b ON a.ClientID = b.ClientID
				WHERE 1 = 1 '
	IF @STATUS IS NOT NULL
		SET @SQL = @SQL + ' AND ServiceStatusID = @STATUS '
	IF @MANAGER IS NOT NULL
		SET @SQL = @SQL + ' AND ManagerID = @MANAGER '
	IF @SERVICE IS NOT NULL
		SET @SQL = @SQL + ' AND ServiceID = @SERVICE '
	IF @TYPE IS NOT NULL
		SET @SQL = @SQL + ' AND a.ClientID IN (SELECT ClientID FROM dbo.ClientTable WHERE STATUS = 1 AND ClientContractTypeID IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE))) '

	SET @SQL = @SQL + '
			) AS dt'
	IF @DATE IS NOT NULL
		SET @SQL = @SQL + '
		WHERE ConnectDate >= @DATE'		
	SET @SQL = @SQL + '		
		ORDER BY ClientFullName '

	--PRINT @SQL

	EXEC sp_executesql @SQL, N'@STATUS INT, @MANAGER INT, @SERVICE INT, @DATE SMALLDATETIME, @TYPE VARCHAR(MAX)', @STATUS, @MANAGER, @SERVICE, @DATE, @TYPE
END