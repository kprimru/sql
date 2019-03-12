USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Din].[DIN_SEARCH_NEW]
	@CLIENT		NVARCHAR(MAX) = NULL,
	@CLIENT_ID	NVARCHAR(MAX) = NULL,
	@SYS		NVARCHAR(MAX) = NULL,
	@TYPE		NVARCHAR(MAX) = NULL,
	@NET		NVARCHAR(MAX) = NULL,
	@DISTR		INT			  = NULL,
	@NAME		NVARCHAR(256) = NULL,
	@UNREG		BIT			  = 0,
	@BEGIN		SMALLDATETIME = NULL,
	@END		SMALLDATETIME = NULL,
	@COMPL_CHECK	NVARCHAR(MAX) = NULL,
	@COMPLECT		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CHECKED BIT
	
	SET @CLIENT = NULLIF(@Client, '');

	IF @CLIENT IS NULL AND @CLIENT_ID IS NULL AND @SYS IS NULL AND @TYPE IS NULL AND @NET IS NULL AND @DISTR IS NULL AND @NAME IS NULL AND @BEGIN IS NULL AND @END IS NULL AND @UNREG = 0-- AND @COMPL_CHECK IS NULL AND @COMPLECT IS NULL
		SET @BEGIN = dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))

	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din
		
	CREATE TABLE #din
		(
			ID INT PRIMARY KEY, 
			ID_HOST	INT,
			DISTR	INT,
			COMP	TINYINT
		)
	IF @CLIENT_ID IS NOT NULL
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_DISTR IN
					(
						SELECT DISTR
						FROM dbo.ClientDistrView WITH (NOEXPAND)
						WHERE ID_CLIENT = @CLIENT_ID
					)

	ELSE IF @CLIENT IS NOT NULL
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_DISTR IN
					(
						SELECT DISTR
						FROM dbo.ClientDistrView WITH (NOEXPAND)
						WHERE ID_CLIENT IN
							(
								SELECT ClientID
								FROM dbo.ClientTable
								WHERE /*(ClientFullName LIKE ('%'+@CLIENT+'%'))OR*/(ClientShortName LIKE ('%'+@CLIENT+'%'))
							)
					)

	ELSE IF @SYS IS NOT NULL
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_ID IN
				(
					SELECT DF_ID
					FROM 
						Din.DinFiles
						INNER JOIN dbo.TableIDFromXML(@SYS) ON DF_ID_SYS = ID
				)

	ELSE IF @TYPE IS NOT NULL
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_ID IN
					(
						SELECT DF_ID
						FROM 
							Din.DinFiles
							INNER JOIN dbo.TableIDFromXML(@TYPE) ON DF_ID_TYPE = ID
					)
	
	ELSE IF @NET IS NOT NULL
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_ID IN
				(
					SELECT DF_ID
					FROM 
						Din.DinFiles
						INNER JOIN dbo.TableIDFromXML(@NET) ON DF_ID_NET = ID
				)

	ELSE
	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_DISTR = @DISTR OR @DISTR IS NULL

	IF @CLIENT IS NOT NULL
		DELETE 
		FROM #din
		WHERE DISTR NOT IN
			(
				SELECT DISTR
				FROM dbo.ClientDistrView WITH (NOEXPAND)
				WHERE ID_CLIENT IN
					(
						SELECT ClientID
						FROM dbo.ClientTable
						WHERE /*(ClientFullName LIKE ('%'+@CLIENT+'%'))OR*/(ClientShortName LIKE ('%'+@CLIENT+'%'))
					)
			)
	
	/*IF @CLIENT_ID IS NOT NULL
		DELETE
		FROM #din
		WHERE  DISTR NOT IN 
				(
					SELECT DISTR
					FROM dbo.ClientDistrView WITH (NOEXPAND)
					WHERE ID_CLIENT = @CLIENT_ID
				)*/
	
	IF @SYS IS NOT NULL
		DELETE 
		FROM #din
		WHERE ID NOT IN
			(
				SELECT DF_ID
				FROM 
					Din.DinFiles
					INNER JOIN dbo.TableIDFromXML(@SYS) ON DF_ID_SYS = ID
			)
			
	IF @TYPE IS NOT NULL
		DELETE 
		FROM #din
		WHERE ID NOT IN
			(
				SELECT DF_ID
				FROM 
					Din.DinFiles
					INNER JOIN dbo.TableIDFromXML(@TYPE) ON DF_ID_TYPE = ID
			)
		
	IF @NET IS NOT NULL
		DELETE 
		FROM #din
		WHERE ID NOT IN
			(
				SELECT DF_ID
				FROM 
					Din.DinFiles
					INNER JOIN dbo.TableIDFromXML(@NET) ON DF_ID_NET = ID
			)
		
	IF @BEGIN IS NOT NULL OR @END IS NOT NULL
		DELETE
		FROM #din
		WHERE ID NOT IN
			(
				SELECT DF_ID
				FROM Din.DinFiles
				WHERE (DF_CREATE >= @BEGIN OR @BEGIN IS NULL)
					AND (DF_CREATE <= @END OR @END IS NULL)
			)
		
	IF @UNREG = 1
		DELETE
		FROM #din
		WHERE EXISTS
			(
				SELECT *
				FROM dbo.RegNodeCurrentView WITH(NOEXPAND)
				WHERE ID_HOST = HostID AND DistrNumber = DISTR AND CompNumber = COMP
			)


	SELECT 
		a.ID, CONVERT(int, Null) AS MASTER_ID, b.DIS_STR, c.DistrNumber, CASE b.DF_RIC WHEN 20 THEN NULL ELSE b.DF_RIC END AS DF_RIC, 
		b.DF_CREATE, b.SST_SHORT, b.NT_SHORT, 
		DS_INDEX, 
		Comment, RegisterDate,
		REVERSE(STUFF(REVERSE(RTRIM(
			(
				SELECT SystemShortName + ' (' + NT_SHORT + '), '
				FROM
					(
						SELECT DISTINCT SystemShortName, NT_SHORT, SystemOrder, NT_TECH, NT_NET		
						FROM Din.DinView z WITH(NOEXPAND)
						WHERE a.ID_HOST = z.HostID AND a.DISTR = z.DF_DISTR AND a.COMP = z.DF_COMP
							AND (z.NT_ID <> b.NT_ID OR z.SystemID <> b.SystemID)		
					) AS o_O
				ORDER BY SystemOrder, NT_TECH, NT_NET FOR XML PATH('')
			))), 1, 1, '')) AS EXCHANGE,
		CASE @COMPL_CHECK 
		WHEN Complect 
		THEN 
			CASE DS_INDEX
			WHEN 0
			THEN CONVERT(BIT, 1)
			END 
		ELSE CONVERT(BIT, 0) 
		END AS CHECKED,
		Complect
	INTO #distr
	FROM 
		#din a
		INNER JOIN Din.DinView b WITH(NOEXPAND) ON DF_ID = ID
		LEFT OUTER JOIN Reg.RegNodeSearchView c WITH(NOEXPAND) ON a.ID_HOST = c.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
	WHERE (Comment LIKE @NAME OR @NAME IS NULL)AND(Complect LIKE '%'+@COMPLECT+'%' OR @COMPLECT IS NULL)
	ORDER BY Complect, b.SystemOrder, a.DISTR, a.COMP ASC


-----------------------------������ ������ ���������� ������������ ����������� � ������� � ��� �������
UPDATE #distr
SET 
	CHECKED=0, 
	DS_INDEX=1,
	MASTER_ID =1
WHERE DIS_STR IN 
			(
				SELECT DIS_STR
				FROM Din.DinView
				WHERE DF_DISTR IN
							(
								SELECT DISTR 
								FROM #din
								GROUP BY ID_HOST, DISTR, COMP
									HAVING COUNT(*)>1
							)
			)
	AND DIS_STR NOT IN
			(
				SELECT DistrStr
				FROM Reg.RegNodeSearchView
			)

UPDATE v
SET
	MASTER_ID = f.ID
FROM #distr v
	INNER JOIN #distr f ON (v.DistrNumber=f.DistrNumber AND f.MASTER_ID IS NULL)
WHERE v.MASTER_ID = 1
-------------------------------����� ������� ����������� ��������� ��������� ��� �������� �� ��������----------------
IF @CLIENT_ID IS NOT NULL
	UPDATE #distr
	SET CHECKED=1 
	WHERE (Complect IN
		(
				SELECT TOP (1) Complect
				FROM #distr
				WHERE DS_INDEX=0
		))
		AND
		(
			DS_INDEX=0
		)


	
	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din


SELECT * FROM #distr

END