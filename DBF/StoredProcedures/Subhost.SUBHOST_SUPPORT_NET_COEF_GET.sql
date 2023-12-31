USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_SUPPORT_NET_COEF_GET]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT = NULL
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

		DECLARE @PR_DATE	SMALLDATETIME

		SELECT @PR_DATE = PR_DATE
		FROM dbo.PeriodTable
		WHERE PR_ID = @PR_ID

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		CREATE TABLE #sgr
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				TITLE VARCHAR(100),
				SN_ID SMALLINT,
				COEF DECIMAL(8, 4),
				COEF_OLD DECIMAL(8, 4),
				COEF_NEW DECIMAL(8, 4)
			)

		IF @PR_DATE >= '20140101'
		BEGIN
			IF @SH_ID IN (12)
				INSERT INTO #sgr(TITLE, SN_ID, COEF)
					SELECT SN_NAME, SN_ID, SNCC_VALUE
					FROM
						(
							SELECT
								SN_NAME, SN_ID, SNCC_VALUE,
								(
									SELECT MAX(SNC_NET_COUNT)
									FROM dbo.SystemNetCountTable
									WHERE SNC_ID_SN = SN_ID
								) AS NET_COUNT,
								(
									SELECT MAX(SNC_TECH)
									FROM dbo.SystemNetCountTable
									WHERE SNC_ID_SN = SN_ID
								) AS TECH_TYPE
							FROM
								dbo.SystemNetTable
								INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
							WHERE SNCC_ID_PERIOD = @PR_ID
						) AS o_O
					ORDER BY TECH_TYPE, NET_COUNT, SNCC_VALUE
			ELSE
				INSERT INTO #sgr(TITLE, SN_ID, COEF)
					SELECT SN_NAME, SN_ID, SNCC_SUBHOST
					FROM
						(
							SELECT
								SN_NAME, SN_ID, SNCC_SUBHOST,
								(
									SELECT MAX(SNC_NET_COUNT)
									FROM dbo.SystemNetCountTable
									WHERE SNC_ID_SN = SN_ID
								) AS NET_COUNT,
								(
									SELECT MAX(SNC_TECH)
									FROM dbo.SystemNetCountTable
									WHERE SNC_ID_SN = SN_ID
								) AS TECH_TYPE
							FROM
								dbo.SystemNetTable
								INNER JOIN dbo.SystemNetCoef ON SNCC_ID_SN = SN_ID
							WHERE SNCC_ID_PERIOD = @PR_ID
						) AS o_O
					ORDER BY TECH_TYPE, NET_COUNT, SNCC_SUBHOST
		END
		ELSE
			INSERT INTO #sgr(TITLE, SN_ID, COEF)
				SELECT SN_NAME, SN_ID, SN_COEF
				FROM dbo.SystemNetTable
				ORDER BY SN_COEF

		SELECT *
		FROM #sgr
		ORDER BY ID

		IF OBJECT_ID('tempdb..#sgr') IS NOT NULL
			DROP TABLE #sgr

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_SUPPORT_NET_COEF_GET] TO rl_subhost_calc;
GO
