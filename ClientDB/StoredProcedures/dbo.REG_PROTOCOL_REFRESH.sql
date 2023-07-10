USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[REG_PROTOCOL_REFRESH]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[REG_PROTOCOL_REFRESH]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[REG_PROTOCOL_REFRESH]
	@CNT	INT = NULL OUTPUT
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

		DECLARE @cmd NVARCHAR(512)

		DECLARE @ERROR	VARCHAR(MAX)

		--SET @cmd = '\\BIM\vol2\Vedareg\Vedareg\ConsReg\consreg.exe /base* /saveptl:\\PC275-sql\ptl\consreg_client.ptl'
		--SET @cmd = Maintenance.GlobalConsregPath() + ' /T:7 /DATE:01.10.2019 /base* /saveptl:\\PC275-sql\ptl\consreg_client.ptl'
		DECLARE @ProtocolPath VARCHAR(500)

		SELECT TOP(1) @ProtocolPath = GS_VALUE
		FROM Maintenance.GlobalSettings
		WHERE GS_NAME = 'PROTOCOL_PATH'

		SELECT @ProtocolPath AS ProtocolPath

		SET @cmd = Maintenance.GlobalConsregPath() + ' /T:7 /base* /saveptl:' + @ProtocolPath

		EXEC xp_cmdshell @cmd, no_output

		IF OBJECT_ID('tempdb..#ptl') IS NOT NULL
			DROP TABLE #ptl

		CREATE TABLE #ptl
			(
				PTL_DATE	VARCHAR(64),
				PTL_HOST	VARCHAR(64),
				PTL_DISTR	VARCHAR(64),
				PTL_OPER	VARCHAR(256),
				PTL_REG		VARCHAR(64),
				PTL_TYPE	VARCHAR(64),
				PTL_TEXT	VARCHAR(512),
				PTL_COMP	VARCHAR(64),
				PTL_USER	VARCHAR(64)
		)

		DECLARE @ConfigPath VARCHAR(100)

		SELECT TOP(1) @ConfigPath = GS_VALUE
		FROM Maintenance.GlobalSettings
		WHERE GS_NAME = 'CONFIG_PATH'

		SELECT @ConfigPath AS ConfigPath

		EXEC('
		BULK INSERT #ptl
		FROM ''\\PC2023-SQL\ptl\consreg_client.ptl''
		WITH (FIRSTROW = 2, FORMATFILE = ' + @ConfigPath);

		UPDATE #ptl
		SET PTL_OPER = ISNULL(PTL_OPER, ''),
			PTL_TYPE = ISNULL(PTL_TYPE, ''),
			PTL_TEXT = ISNULL(PTL_TEXT, ''),
			PTL_COMP = ISNULL(PTL_COMP, ''),
			PTL_USER = ISNULL(PTL_USER, '')
		WHERE PTL_OPER IS NULL
			OR PTL_TYPE IS NULL
			OR PTL_TEXT IS NULL
			OR PTL_COMP IS NULL
			OR PTL_USER IS NULL

		ALTER TABLE #ptl
			ADD PTL_DATE_FMT DATETIME,
				PTL_DISTR_FMT INT,
				PTL_COMP_FMT TINYINT,
				PTL_REG_FMT TINYINT

		UPDATE #ptl
		SET PTL_DATE_FMT = CONVERT(DATETIME,
							SUBSTRING(PTL_DATE, 7, 4) + '-' +
							SUBSTRING(PTL_DATE, 4, 2) + '-' +
							SUBSTRING(PTL_DATE, 1, 2) + ' ' +
							SUBSTRING(PTL_DATE, 13, 2) + ':' +
							SUBSTRING(PTL_DATE, 16, 2) + ':' +
							SUBSTRING(PTL_DATE, 19, 2)
							, 120),
			PTL_DISTR_FMT = CONVERT(INT,
								CASE CHARINDEX('_', PTL_DISTR)
									WHEN 0 THEN PTL_DISTR
									ELSE LEFT(PTL_DISTR, CHARINDEX('_', PTL_DISTR) - 1)
								END
							),
			PTL_COMP_FMT = CONVERT(TINYINT,
								CASE CHARINDEX('_', PTL_DISTR)
									WHEN 0 THEN 1
									ELSE RIGHT(PTL_DISTR, LEN(PTL_DISTR) - CHARINDEX('_', PTL_DISTR))
								END
							),
			PTL_REG_FMT = CONVERT(TINYINT, PTL_REG)

		SELECT @ERROR = TP + ': ' + MSG + CHAR(10)
		FROM
			(
				SELECT DISTINCT 'Неизвестный хост' AS TP, PTL_HOST AS MSG
				FROM #ptl
				WHERE NOT EXISTS
						(
							SELECT *
							FROM dbo.Hosts
							WHERE PTL_HOST = HostReg
						)
			) AS o_O

		IF @ERROR IS NOT NULL
		BEGIN
			PRINT @ERROR

			EXEC Maintenance.MAIL_SEND @ERROR

			IF OBJECT_ID('tempdb..#reg') IS NOT NULL
				DROP TABLE #reg

			RETURN
		END

		INSERT INTO dbo.RegProtocol(
				RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER,
				RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER
				)
			SELECT
				PTL_DATE_FMT, HostID, PTL_DISTR_FMT, PTL_COMP_FMT, PTL_OPER,
				PTL_REG_FMT, PTL_TYPE, PTL_TEXT, PTL_USER, PTL_COMP
			FROM
				#ptl a
				INNER JOIN dbo.Hosts c ON PTL_HOST = HostReg
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.RegProtocol b
					WHERE a.PTL_DATE_FMT = b.RPR_DATE
						AND c.HostID = b.RPR_ID_HOST
						AND ISNULL(a.PTL_DISTR_FMT, 0) = ISNULL(b.RPR_DISTR, 0)
						AND ISNULL(a.PTL_COMP_FMT, 0) = ISNULL(b.RPR_COMP, 0)
						AND a.PTL_OPER = b.RPR_OPER
						AND ISNULL(a.PTL_REG_FMT, 0) = ISNULL(b.RPR_REG, 0)
						AND a.PTL_TYPE = b.RPR_TYPE
						AND a.PTL_TEXT = b.RPR_TEXT
						AND a.PTL_USER = b.RPR_USER
						AND a.PTL_COMP = b.RPR_COMPUTER
				)

		SET @CNT = @@ROWCOUNT


		IF OBJECT_ID('tempdb..#ptl') IS NOT NULL
			DROP TABLE #ptl

		EXEC [dbo].[DISTR_EMAIL_LOAD_FROM_PROTOCOL];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REG_PROTOCOL_REFRESH] TO rl_reg_protocol_refresh;
GO
