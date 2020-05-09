USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_SUBHOST_DB_SELECT]
	@DB	NVARCHAR(512) = NULL
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

		SELECT REPLICATE('0', 5 - LEN(CONVERT(VARCHAR(20), RNUM))) + CONVERT(VARCHAR(20), RNUM) AS RN, RNUM, UF_NAME, UF_CREATE, UF_DATA
		FROM
			(
				SELECT ROW_NUMBER() OVER(PARTITION BY UF_NAME ORDER BY UF_DATE) AS RNUM, UF_NAME, UF_CREATE, UF_DATA
				FROM
					(
						SELECT UF_NAME, UF_CREATE, UF_DATA, UF_DATE
						FROM
							[PC275-SQL\GAMMA].ClientArtDB.USR.USRFile a
							INNER JOIN [PC275-SQL\GAMMA].ClientArtDB.USR.USRFileData b ON a.UF_ID = b.UF_ID
						WHERE UF_CREATE >= DATEADD(MONTH, -3, GETDATE())
							AND NOT EXISTS
								(
									SELECT *
									FROM USR.USRFile z
									INNER JOIN USR.USRFileData y ON z.UF_ID = y.UF_ID
									WHERE y.UF_DATA = b.UF_DATA
										AND a.UF_MD5 = z.UF_MD5
										AND z.UF_DATE = a.UF_DATE
								)

						UNION ALL

						SELECT UF_NAME, UF_CREATE, UF_DATA, UF_DATE
						FROM
							[PC275-SQL\GAMMA].ClientNahDB.USR.USRFile a
							INNER JOIN [PC275-SQL\GAMMA].ClientNahDB.USR.USRFileData b ON a.UF_ID = b.UF_ID
						WHERE UF_CREATE >= DATEADD(MONTH, -3, GETDATE())
							AND NOT EXISTS
								(
									SELECT *
									FROM USR.USRFile z
									INNER JOIN USR.USRFileData y ON z.UF_ID = y.UF_ID
									WHERE y.UF_DATA = b.UF_DATA
										AND a.UF_MD5 = z.UF_MD5
										AND z.UF_DATE = a.UF_DATE
								)

						UNION ALL

						SELECT UF_NAME, UF_CREATE, UF_DATA, UF_DATE
						FROM
							[PC275-SQL\GAMMA].ClientSlavDB.USR.USRFile a
							INNER JOIN [PC275-SQL\GAMMA].ClientSlavDB.USR.USRFileData b ON a.UF_ID = b.UF_ID
						WHERE UF_CREATE >= DATEADD(MONTH, -3, GETDATE())
							AND NOT EXISTS
								(
									SELECT *
									FROM USR.USRFile z
									INNER JOIN USR.USRFileData y ON z.UF_ID = y.UF_ID
									WHERE y.UF_DATA = b.UF_DATA
										AND a.UF_MD5 = z.UF_MD5
										AND z.UF_DATE = a.UF_DATE
								)

						UNION ALL

						SELECT UF_NAME, UF_CREATE, UF_DATA, UF_DATE
						FROM
							[PC275-SQL\GAMMA].ClientUSSDB.USR.USRFile a
							INNER JOIN [PC275-SQL\GAMMA].ClientUSSDB.USR.USRFileData b ON a.UF_ID = b.UF_ID
						WHERE UF_CREATE >= DATEADD(MONTH, -3, GETDATE())
							AND NOT EXISTS
								(
									SELECT *
									FROM USR.USRFile z
									INNER JOIN USR.USRFileData y ON z.UF_ID = y.UF_ID
									WHERE y.UF_DATA = b.UF_DATA
										AND a.UF_MD5 = z.UF_MD5
										AND z.UF_DATE = a.UF_DATE
								)
					) AS o_O
			) AS o_O
		ORDER BY RNUM

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
