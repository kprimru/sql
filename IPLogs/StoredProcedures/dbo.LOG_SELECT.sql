USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[LOG_SELECT]
	@CLIENT			INT,
	@CLIENT_TYPE	NVARCHAR(20),
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME,
	@TXT	BIT,
	@RES	BIT,
	@LET	BIT
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

	    --IF @BEGIN IS NULL
	    --	SET @BEGIN = DATEADD(DAY, -7, GETDATE())

	    SELECT
		    FL_ID, FL_NAME,
		    CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), LF_DATE, 112), 112) AS LF_DAY,
		    LF_DATE, LF_SHORT, LF_TEXT
	    FROM
		    dbo.LogFiles z INNER JOIN
		    dbo.Files y ON z.LF_ID_FILE = y.FL_ID
	    WHERE (LF_DATE >= @BEGIN OR @BEGIN IS NULL)
		    AND (LF_DATE <= @END OR @END IS NULL)
		    AND (@TXT = 1 OR LF_TYPE NOT IN (''))
		    AND (@RES = 1 OR LF_TYPE NOT IN ('result'))
		    AND (@LET = 1 OR LF_TYPE NOT IN ('letter'))
		    AND @CLIENT_TYPE = 'OIS'
		    AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\ALPHA].ClientDB.dbo.ClientDistrView b WITH(NOEXPAND) INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON b.SystemID = c.SystemID
				    WHERE ID_CLIENT = @CLIENT
					    AND SystemNumber = LF_SYS
					    AND LF_DISTR = DISTR
					    AND LF_COMP = COMP
			    )
    
	    UNION ALL

	    SELECT
		    FL_ID, FL_NAME,
		    CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), LF_DATE, 112), 112),
		    LF_DATE, LF_SHORT, LF_TEXT
	    FROM dbo.LogFiles z INNER JOIN
		    dbo.Files y ON z.LF_ID_FILE = y.FL_ID
	    WHERE (LF_DATE >= @BEGIN OR @BEGIN IS NULL)
		    AND (LF_DATE <= @END OR @END IS NULL)
		    AND (@TXT = 1 OR LF_TYPE NOT IN (''))
		    AND (@RES = 1 OR LF_TYPE NOT IN ('result'))
		    AND (@LET = 1 OR LF_TYPE NOT IN ('letter'))
		    AND @CLIENT_TYPE = 'DBF'
		    AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\DELTA].DBF.dbo.TODistrTable b INNER JOIN
					    [PC275-SQL\DELTA].DBF.dbo.DistrView c ON c.DIS_ID = b.TD_ID_DISTR INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable d ON SystemBaseName = SYS_REG_NAME
				    WHERE TD_ID_TO = @CLIENT
					    AND LF_SYS = SystemNumber
					    AND LF_DISTR = DIS_NUM
					    AND LF_COMP = DIS_COMP_NUM
			    )

	    UNION ALL

	    SELECT
		    FL_ID, FL_NAME,
		    CONVERT(SMALLDATETIME, CONVERT(VARCHAR(20), LF_DATE, 112), 112),
		    LF_DATE, LF_SHORT, LF_TEXT
	    FROM dbo.LogFiles z INNER JOIN
		    dbo.Files y ON z.LF_ID_FILE = y.FL_ID
	    WHERE (LF_DATE >= @BEGIN OR @BEGIN IS NULL)
		    AND (LF_DATE <= @END OR @END IS NULL)
		    AND (@TXT = 1 OR LF_TYPE NOT IN (''))
		    AND (@RES = 1 OR LF_TYPE NOT IN ('result'))
		    AND (@LET = 1 OR LF_TYPE NOT IN ('letter'))
		    AND @CLIENT_TYPE = 'REG'
		    AND EXISTS
			    (
				    SELECT *
				    FROM
					    [PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable b INNER JOIN
					    [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable c ON b.SystemName = c.SystemBaseName
				    WHERE ID = @CLIENT
					    AND SystemNumber = LF_SYS
					    AND LF_DISTR = DistrNumber
					    AND LF_COMP = CompNumber
			    )
	    ORDER BY LF_DATE DESC

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[LOG_SELECT] TO rl_client_stat;
GO
