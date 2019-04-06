USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[REFRESH_REG_NODE]
	@REG_PATH NVARCHAR(500) = NULL,
	@BCP_PATH NVARCHAR(500) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SQL NVARCHAR(MAX)

	DECLARE @result INT


	IF @REG_PATH IS NULL AND @BCP_PATH IS NULL
	BEGIN
		DECLARE @REG_NODE NVARCHAR(500) /* путь к consreg */
		DECLARE @SAVE NVARCHAR(500) /* путь для сохраненного файла */

		SET @SAVE = 'E:\SQLScript\ImportReg\reg' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(50), GETDATE(), 121), '-', ''), ':', ''), ' ', ''), '.', '') + '.csv'

		DECLARE @CMD NVARCHAR(1024)

		--SET @CMD = '\\BIM\vol2\vedareg\vedareg\consreg\consreg.exe /outcsv:' + @SAVE + ' /BASE* /ALL'
		SET @CMD = Maintenance.GlobalConsregPath() + ' /outcsv:' + @SAVE + ' /BASE* /ALL'

		EXEC @result = master..xp_cmdshell @CMD, NO_OUTPUT

		IF (@result <> 0)
			RETURN

		IF OBJECT_ID('tempdb..#rn') IS NOT NULL
			DROP TABLE #rn
		
		CREATE TABLE #rn
			(
				SystemName varchar(20),
				DistrNumber int,
				CompNumber tinyint,
				DistrType varchar(20),
				TechnolType varchar(20),
				NetCount int,
				SubHost int,
				TransferCount int,
				TransferLeft int,
				Service int,
				RegisterDate varchar(20),
				Comment varchar(255),
				Complect varchar(20)
			)

		SET @sql = '
				BULK INSERT #rn
				FROM ''' + @SAVE + '''
				WITH
					(
						FORMATFILE = ''E:\SQLScript\ImportReg\bcp.fmt'',
						FIRSTROW = 2
					)'	

		EXEC sp_executesql @sql

		CREATE CLUSTERED INDEX IX_RN_DATA ON #rn (DistrNumber, SystemName, CompNumber)

		IF EXISTS(SELECT * FROM #rn)
		BEGIN
			/*TRUNCATE TABLE RegNodeTable		

			DBCC CHECKIDENT ('dbo.RegNodeTable', RESEED, 1) WITH NO_INFOMSGS
			*/

			UPDATE #rn
			SET Comment = REPLACE(LEFT(RIGHT(Comment, LEN(Comment) - 1), LEN(Comment) - 2), '""', '"')
			WHERE SUBSTRING(Comment, 1, 1) = '"' AND SUBSTRING(Comment, LEN(Comment), 1) = '"'

			DELETE 
			FROM dbo.RegNodeTable
			WHERE NOT EXISTS
				(
					SELECT *
					FROM #rn
					WHERE #rn.SystemName = RegNodeTable.SystemName
						AND #rn.DistrNumber = RegNodeTable.DistrNumber
						AND #rn.CompNumber = RegNodeTable.CompNumber
				)

			UPDATE t
			SET t.DistrType = r.DistrType,
				t.TechnolType = r.TechnolType,
				t.NetCount = r.NetCount,
				t.SubHost = r.SubHost,
				t.TransferCount = r.TransferCount,
				t.TransferLeft = r.TransferLeft,
				t.Service = r.Service,
				t.RegisterDate = r.RegisterDate,
				t.Comment = r.Comment,
				t.Complect = r.Complect
			FROM dbo.RegNodeTable t
				INNER JOIN #rn r ON t.SystemName = r.SystemName
								AND t.DistrNumber = r.DistrNumber
								AND t.CompNumber = r.CompNumber
			WHERE
				(
					t.DistrType <> r.DistrType
					OR	t.TechnolType <> r.TechnolType
					OR	t.NetCount <> r.NetCount
					OR	t.SubHost <> r.SubHost
					OR	t.TransferCount <> r.TransferCount
					OR	t.TransferLeft <> r.TransferLeft
					OR	t.Service <> r.Service
					OR	ISNULL(t.RegisterDate, '19910101') <> ISNULL(r.RegisterDate, '19910101')
					OR	ISNULL(t.Comment, '') <> ISNULL(r.Comment, '')
					OR	ISNULL(t.Complect, '') <> ISNULL(r.Complect, '')
				)

			INSERT INTO dbo.RegNodeTable(SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect)
				SELECT *
				FROM #rn a
				WHERE NOT EXISTS
					(
						SELECT *
						FROM dbo.RegNodeTable b
						WHERE a.SystemName = b.SystemName
							AND a.DistrNumber = b.DistrNumber
							AND a.CompNumber = b.CompNumber
					)

			/*INSERT INTO RegNodeTable
				SELECT *
				FROM #rn
				*/
		END

		IF OBJECT_ID('tempdb..#rn') IS NOT NULL
			DROP TABLE #rn
	
		SET @CMD = 'DEL ' + @SAVE

		EXEC master..xp_cmdshell @CMD, NO_OUTPUT
	END
	ELSE
		BEGIN

			IF OBJECT_ID('tempdb..#reg') IS NOT NULL
				DROP TABLE #reg

			CREATE TABLE #reg
				(
					SystemName varchar(20) NOT NULL,
					[DistrNumber] [int] NULL,
					[CompNumber] [tinyint] NULL,
					[DistrType] [varchar](20) NULL,
					[TechnolType] [varchar](20) NULL,
					[NetCount] [int] NULL,
					[SubHost] [int] NULL,
					[TransferCount] [int] NULL,
					[TransferLeft] [int] NULL,
					[Service] [int] NULL,
					[RegisterDate] [varchar](20) NULL,
					[Comment] [varchar](255) NULL,
					[Complect] [varchar](20) NULL
				)
 
			SET @sql = '
				BULK INSERT #reg
				FROM ''' + @REG_PATH + '''
				WITH
					(
						FORMATFILE = ''' + @BCP_PATH + ''',
						FIRSTROW = 2
					)'
			/*SELECT 1 AS ER_MSG, @sql*/
			EXEC sp_executesql @sql

			DELETE FROM dbo.RegNodeTable

			INSERT INTO dbo.RegNodeTable(SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect)
				SELECT SystemName, DistrNumber, CompNumber, DistrType, TechnolType, NetCount, SubHost, TransferCount, TransferLeft, Service, RegisterDate, Comment, Complect
				FROM #reg

			IF OBJECT_ID('tempdb..#reg') IS NOT NULL
				DROP TABLE #reg
		END
END