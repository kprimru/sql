USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REG_PROTOCOL_LOAD]
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

		DECLARE	@PTL_FILE	NVARCHAR(512)
		DECLARE	@FMT_FILE	NVARCHAR(512)
		DECLARE @REG_PATH	NVARCHAR(512)

		SELECT @REG_PATH = dbo.GET_SETTING('REG_NODE_PATH') + ' ' + dbo.GET_SETTING('PTL_KEYS')

		SELECT @FMT_FILE = dbo.GET_SETTING('PTL_BCP_PATH')
		SELECT @PTL_FILE = dbo.GET_SETTING('TEMP_PTL_PATH')

		DECLARE @cmd NVARCHAR(512)

		SET @cmd = @REG_PATH + @PTL_FILE

		EXEC xp_cmdshell @cmd

		IF OBJECT_ID('tempdb..#ptl') IS NOT NULL
			DROP TABLE #ptl

		CREATE TABLE #ptl
			(
				PTL_DATE	VARCHAR(64),
				PTL_HOST	VARCHAR(64),
				PTL_DISTR	VARCHAR(64),
				PTL_OPER	VARCHAR(255),
				PTL_REG		VARCHAR(64),
				PTL_TYPE	VARCHAR(64),
				PTL_TEXT	VARCHAR(512),
				PTL_COMP	VARCHAR(64),
				PTL_USER	VARCHAR(64)
		)

		EXEC('
		BULK INSERT #ptl
		FROM ''' + @PTL_FILE + '''
		WITH (FIRSTROW = 2, FORMATFILE = ''' + @FMT_FILE + ''');');
	    
		INSERT INTO dbo.RegProtocol(
				RPR_DATE, RPR_ID_HOST, RPR_DISTR, RPR_COMP, RPR_OPER,
				RPR_REG, RPR_TYPE, RPR_TEXT, RPR_USER, RPR_COMPUTER
				)
			SELECT
				PTL_DATE, HST_ID, PTL_DISTR, PTL_COMP, PTL_OPER,
				PTL_REG, PTL_TYPE, PTL_TEXT, PTL_USER, PTL_COMPUTER
			FROM
				(
					SELECT
						CONVERT(DATETIME,
							SUBSTRING(PTL_DATE, 7, 4) + '-' +
							SUBSTRING(PTL_DATE, 4, 2) + '-' +
							SUBSTRING(PTL_DATE, 1, 2) + ' ' +
							SUBSTRING(PTL_DATE, 13, 2) + ':' +
							SUBSTRING(PTL_DATE, 16, 2) + ':' +
							SUBSTRING(PTL_DATE, 19, 2)
						, 120) AS PTL_DATE,
						HST_ID,
						CONVERT(INT,
							CASE CHARINDEX('_', PTL_DISTR)
								WHEN 0 THEN PTL_DISTR
								ELSE LEFT(PTL_DISTR, CHARINDEX('_', PTL_DISTR) - 1)
							END
						) AS PTL_DISTR,
						CONVERT(TINYINT,
							CASE CHARINDEX('_', PTL_DISTR)
								WHEN 0 THEN 1
								ELSE RIGHT(PTL_DISTR, LEN(PTL_DISTR) - CHARINDEX('_', PTL_DISTR))
							END
						) AS PTL_COMP,
						PTL_OPER, PTL_REG, PTL_TYPE, PTL_TEXT, PTL_USER, PTL_COMP AS PTL_COMPUTER
					FROM
						#ptl
						INNER JOIN dbo.HostTable ON PTL_HOST = HST_REG_FULL
				) a
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.RegProtocol b
					WHERE a.PTL_DATE = b.RPR_DATE
						AND a.HST_ID = b.RPR_ID_HOST
						AND ISNULL(a.PTL_DISTR, 0) = ISNULL(b.RPR_DISTR, 0)
						AND ISNULL(a.PTL_COMP, 0) = ISNULL(b.RPR_COMP, 0)
						AND ISNULL(a.PTL_OPER, '') = ISNULL(b.RPR_OPER, '')
						AND ISNULL(a.PTL_REG, '') = ISNULL(b.RPR_REG, '')
						AND ISNULL(a.PTL_TYPE, '') = ISNULL(b.RPR_TYPE, '')
						AND ISNULL(a.PTL_TEXT, '') = ISNULL(b.RPR_TEXT, '')
						AND ISNULL(a.PTL_USER, '') = ISNULL(b.RPR_USER, '')
						AND ISNULL(a.PTL_COMPUTER, '') = ISNULL(b.RPR_COMPUTER, '')
				)

		IF OBJECT_ID('tempdb..#ptl') IS NOT NULL
			DROP TABLE #ptl

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[REG_PROTOCOL_LOAD] TO rl_reg_protocol_w;
GO