USE [IPLogs]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[FILES_USR_SELECT]
	@LAST_DATE	BIT,
	@BEGIN		DATETIME,
	@END		DATETIME
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

	    IF @LAST_DATE = 1
	    BEGIN
		    SELECT
			    FL_ID, FL_NAME,
			    CONVERT(DECIMAL(24, 8), CONVERT(DECIMAL(24, 8), FL_SIZE) / 1024) AS FL_SIZE,
			    FL_DATE, UF_USR_NAME, UF_USR_DATA
		    FROM
			    (
				    SELECT UF_USR_NAME AS USR_NAME, MAX(FL_DATE) AS USR_MAX_DATE
				    FROM
					    dbo.Files INNER JOIN
					    dbo.USRFiles I ON FL_ID = UF_ID_FILE
				    WHERE FL_TYPE = 4 AND UF_USR_NAME <> '' AND UF_USR_DATA IS NOT NULL
					    AND NOT EXISTS
						    (
							    SELECT *
							    FROM [PC275-SQL\ALPHA].[ClientDB].USR.USRFile C
							    WHERE I.UF_USR_NAME = C.UF_NAME
								    AND I.UF_MD5 = C.UF_HASH
						    )
				    GROUP BY UF_USR_NAME
			    ) USR INNER JOIN
			    dbo.USRFiles ON USR_NAME = UF_USR_NAME INNER JOIN
			    dbo.Files ON FL_ID = UF_ID_FILE
		    WHERE FL_TYPE = 4 AND FL_DATE = USR_MAX_DATE
			    --AND FL_DATE >= DATEADD(MONTH, -3, GETDATE())
		    ORDER BY FL_DATE
	    END
	    ELSE
	    BEGIN
		    SELECT
			    FL_ID, FL_NAME,
			    CONVERT(DECIMAL(24, 8), CONVERT(DECIMAL(24, 8), FL_SIZE) / 1024) AS FL_SIZE,
			    FL_DATE, UF_USR_NAME, UF_USR_DATA
		    FROM 
			    dbo.USRFiles  INNER JOIN
			    dbo.Files ON FL_ID = UF_ID_FILE
		    WHERE FL_TYPE = 4
			    AND (FL_DATE >= @BEGIN OR @BEGIN IS NULL)
			    AND (FL_DATE <= @END OR @END IS NULL)
		    ORDER BY FL_DATE DESC
	    END

	    EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[FILES_USR_SELECT] TO rl_files_usr;
GO
