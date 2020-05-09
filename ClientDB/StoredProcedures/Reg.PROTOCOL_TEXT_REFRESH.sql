USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Reg].[PROTOCOL_TEXT_REFRESH]
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

		DECLARE @regpath NVARCHAR(MAX)

		SET @regpath = '\\BIM\VOL2\VEDAREG\VEDAREG\CONSREG\'

		IF OBJECT_ID('tempdb..#reg') IS NOT NULL
			DROP TABLE #reg

		CREATE TABLE #reg
			(
				REG_STR NVARCHAR(1000)
			)

		DECLARE @sql VARCHAR(MAX)

		DECLARE @sys VARCHAR(50)

		DECLARE SYSTEMS CURSOR LOCAL FOR
			SELECT HostReg
			FROM dbo.Hosts
			ORDER BY HostReg

		OPEN SYSTEMS

		FETCH NEXT FROM SYSTEMS INTO @sys

		DECLARE @cmd VARCHAR(1000)
		DECLARE @date VARCHAR(50)
		SET @date = REPLACE(CONVERT(VARCHAR(50), GETDATE(), 121), ':', '-')
		SET @cmd = 'MD "C:\DATA\BULK\' + @date+'"'

		/*SELECT @cmd*/

		EXEC xp_cmdshell @cmd, NO_OUTPUT

		/*RETURN

		TRUNCATE TABLE Reg.ProtocolText
		*/

		DECLARE @file_exists INT

		DECLARE @filepath VARCHAR(500)

		DECLARE @MIN_DATE	SMALLDATETIME
		SET @MIN_DATE = CONVERT(SMALLDATETIME, '20130101', 112)

		SELECT @MIN_DATE

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @cmd = 'XCOPY /V /Y "' + @regpath + @sys + '\' + '#' + @sys + '.txt" "C:\DATA\BULK\' + @date + '"'

			EXEC xp_cmdshell @cmd, NO_OUTPUT

			SET @filepath = 'C:\DATA\BULK\' + @date + '\#' + @sys + '.txt'

			EXECUTE xp_fileexist @filepath, @file_exists OUTPUT

			IF @file_exists = 1
			BEGIN

			SELECT @SYS

			TRUNCATE TABLE #reg

			SET @sql = '
			BULK INSERT #reg
				FROM ''C:\DATA\BULK\' + @date + '\#' + @sys + '.txt''
				WITH
					(
						DATAFILETYPE = ''char'',
						FIRSTROW = 2,
						CODEPAGE = ''CP866''
					)
			'

			EXEC (@sql)

			/*
			 маска
			 первые 10 символов 0 дата
			 с 12 15 символов - номер дистрибутива, который можно распарсить на осн. и компьютера
			 кол-во счетчиков или переносов. 23-27
			 с 28 по 43 - операция
			 остальное - код

			 если нет номера дистрибутива - то другая операция

			 если нет кода - то либо отключение, либо включение, либо восст. счетчиков
			*/
			/*
			SELECT LTRIM(RTRIM(SUBSTRING(REG_STR, 12, 6)))
			FROM #reg
			WHERE LTRIM(RTRIM(SUBSTRING(REG_STR, 12, 6))) <> ''
			*/

			INSERT INTO Reg.ProtocolText
				(
					ID_HOST, DATE, DISTR, COMP, CNT, COMMENT
				)

				SELECT ID_HOST, DATE, DISTR, COMP, CNT, COMMENT
				FROM
					(
						SELECT
							HostID AS ID_HOST,
							CONVERT(SMALLDATETIME, LTRIM(RTRIM(SUBSTRING(REG_STR, 1, 10))), 104) AS DATE,
							/*CONVERT(INT, LTRIM(RTRIM(SUBSTRING(REG_STR, 12, 6)))) AS DISTR,
							CONVERT(TINYINT,
								CASE LTRIM(RTRIM(SUBSTRING(REG_STR, 19, 3)))
									WHEN '' THEN 1
									ELSE LTRIM(RTRIM(SUBSTRING(REG_STR, 19, 3)))
								END) AS COMP, */
							CASE CHARINDEX('/', LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))))
								WHEN 0 THEN CONVERT(INT, LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))))
								ELSE CONVERT(INT,
												LEFT(
														LTRIM(RTRIM(
																SUBSTRING(REG_STR, 11, 14)
																)),
														CHARINDEX('/',
															LTRIM(RTRIM(
																SUBSTRING(REG_STR, 11, 14)
																))
														) - 1)
											)
							END AS DISTR,
							CASE CHARINDEX('/', LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))))
								WHEN 0 THEN CONVERT(TINYINT, 1)
								ELSE CONVERT(TINYINT,
									RIGHT(
											LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))),
											LEN(LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14)))) -
											CHARINDEX('/', LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))))
										)
									)
							END AS COMP,
							CONVERT(INT, LTRIM(RTRIM(SUBSTRING(REG_STR, 23, 4)))) AS CNT,
							LTRIM(RTRIM(SUBSTRING(REG_STR, 28, LEN(REG_STR) - 27))) AS COMMENT
						FROM
							(
								SELECT HostID, REG_STR
								FROM
									#reg INNER JOIN
									dbo.Hosts ON HostReg = @sys
								WHERE LTRIM(RTRIM(SUBSTRING(REG_STR, 11, 14))) <> ''
									AND ISDATE(LTRIM(RTRIM(SUBSTRING(REG_STR, 1, 10)))) = 1
									AND LEN(LTRIM(RTRIM(SUBSTRING(REG_STR, 1, 10)))) = 10
									AND ISNUMERIC(LTRIM(RTRIM(SUBSTRING(REG_STR, 12, 6)))) = 1
									AND CHARINDEX(' ', SUBSTRING(REG_STR, 1, 10)) = 0
							) AS a
					) AS a
				WHERE
					NOT EXISTS
					(
						SELECT *
						FROM Reg.ProtocolText b
						WHERE b.ID_HOST = a.ID_HOST
							AND b.DATE = a.DATE
							AND b.DISTR = a.DISTR
							AND b.COMP = a.COMP
							AND b.CNT = a.CNT
							AND b.COMMENT = a.COMMENT
					)
					AND CONVERT(VARCHAR(20), a.DATE, 112) > '20130101'
			END

			PRINT 'AFTER QUERY'

			FETCH NEXT FROM SYSTEMS INTO @sys
		END

		SET @cmd = 'RD /S /Q "C:\DATA\BULK\' + @date+'\"'

		/*SELECT @cmd*/

		EXEC xp_cmdshell @cmd, NO_OUTPUT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
