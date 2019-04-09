USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Din].[DIN_SEARCH]
	@CLIENT	NVARCHAR(MAX) = NULL,
	@SYS	NVARCHAR(MAX) = NULL,
	@TYPE	NVARCHAR(MAX) = NULL,
	@NET	NVARCHAR(MAX) = NULL,
	@DISTR	INT			  = NULL,
	@NAME	NVARCHAR(256) = NULL,
	@UNREG	BIT			  = 0,
	@BEGIN	SMALLDATETIME = NULL,
	@END	SMALLDATETIME = NULL,
	@COMPL_CHECK	NVARCHAR(MAX) = NULL,
	@COMPLECT		NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CHECKED BIT

	--IF @CLIENT IS NULL AND @SYS IS NULL AND @TYPE IS NULL AND @NET IS NULL AND @DISTR IS NULL AND @NAME IS NULL AND @BEGIN IS NULL AND @END IS NULL AND @UNREG = 0
		--SET @BEGIN = dbo.DateOf(DATEADD(MONTH, -1, GETDATE()))

	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din
		
	CREATE TABLE #din
		(
			ID INT PRIMARY KEY, 
			ID_HOST	INT,
			DISTR	INT,
			COMP	TINYINT
		)

	INSERT INTO #din(ID, ID_HOST, DISTR, COMP)
		SELECT DISTINCT DF_ID, HostID, DF_DISTR, DF_COMP
		FROM 
			Din.DinFiles a
			INNER JOIN dbo.SystemTable b ON a.DF_ID_SYS = b.SystemID
		WHERE DF_DISTR = @DISTR OR @DISTR IS NULL

	--select * from #din

	IF @CLIENT IS NOT NULL
		DELETE 
		FROM #din
		WHERE DISTR NOT IN
			(
				SELECT DISTR
				FROM dbo.ClientDistrView
				WHERE ID_CLIENT IN
					(
						SELECT ClientID
						FROM dbo.ClientTable
						WHERE ClientFullName LIKE ('%'+@CLIENT+'%')
					)
			)

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
				WHERE (DF_CREATE >= @BEGIN OR @BEGIN IS NULL)--����� ���� ����� �������� DF_CREATE �� DF_DATE
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
	/*IF @COMPLECT IS NOT NULL
		DELETE
		FROM #din
		WHERE Complect LIKE ('%'+@COMPLECT+'%')
	
	SELECT * FROM #din*/

	SELECT 
		a.ID, b.DIS_STR, CASE b.DF_RIC WHEN 20 THEN NULL ELSE b.DF_RIC END AS DF_RIC, 
		b.DF_CREATE, b.SST_SHORT, b.NT_SHORT, DS_INDEX, Comment, RegisterDate,
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
		CASE @COMPL_CHECK WHEN Complect THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END AS CHECKED,
		Complect
	FROM 
		#din a
		INNER JOIN Din.DinView b WITH(NOEXPAND) ON DF_ID = ID
		LEFT OUTER JOIN Reg.RegNodeSearchView c /*WITH(NOEXPAND)*/ ON a.ID_HOST = c.HostID AND a.DISTR = c.DistrNumber AND a.COMP = c.CompNumber
	WHERE (Comment LIKE @NAME OR @NAME IS NULL)AND(Complect LIKE '%'+@COMPLECT+'%' OR @COMPLECT IS NULL)
	ORDER BY b.SystemOrder, a.DISTR, a.COMP
	
		
	IF OBJECT_ID('tempdb..#din') IS NOT NULL
		DROP TABLE #din
END

