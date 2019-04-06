USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[MAIN_COMPLECT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MAIN	TABLE (SYS_NAME	VARCHAR(50) PRIMARY KEY)

	INSERT INTO @MAIN(SYS_NAME)
		SELECT 'LAW'
		UNION
		SELECT 'ROS'
		UNION
		SELECT 'BUH'
		UNION
		SELECT 'BUHU'
		UNION
		SELECT 'NBU'
		UNION
		SELECT 'BUHL'
		UNION
		SELECT 'BUHUL'
		UNION
		SELECT 'JUR'
		UNION
		SELECT 'BUD'
		UNION
		SELECT 'MBP'
		UNION 
		SELECT 'BUDU'
		

	SELECT DISTINCT
		Comment AS [Клиент],
		a.Complect AS [Номер комплекта],
		REVERSE(STUFF(REVERSE(
			(
				SELECT 
					dbo.DistrString(SystemShortName, DistrNumber, CompNumber) + '(' +
					CASE TechnolType
						WHEN 1 THEN 'Флэш'
						ELSE
							CASE NetCount
								WHEN 0 THEN 'лок'
								WHEN 1 THEN '1/с'
								ELSE 'сеть ' + CONVERT(VARCHAR(20), NetCount)
							END
					END + ')' + ', '
				FROM 
					dbo.SystemTable b 
					INNER JOIN dbo.RegNodeTable c ON c.SystemName = b.SystemBaseName
					INNER JOIN @MAIN ON SYS_NAME = SystemBaseName
				WHERE c.Complect = a.Complect AND c.Service = 0
				ORDER BY SystemOrder FOR XML PATH('')
			)
		), 1, 2, '')) AS [Дистрибутивы]
	FROM dbo.RegNodeTable a
	WHERE a.Service = 0
		--AND DistrType NOT IN ('NCT', 'ADM', 'NEK')
		AND 
		(
			SELECT COUNT(*)
			FROM 
				dbo.RegNodeTable d 
				INNER JOIN @MAIN ON d.SystemName = SYS_NAME
			WHERE d.Complect = a.Complect AND d.Service = 0
		) > 1
	ORDER BY Comment
END
