USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT_DBF_FILTER]
	@SERVICE	INT,
	@MANAGER	INT,
	@SYSTEM		INT,
	@DISCOUNT	BIT,
	@FIXED		BIT,
	@DISC_START	INT,
	@DISC_END	INT,
	@FIX_START	MONEY,
	@FIX_END	MONEY,
	@TYPE		INT = NULL,
	@REAL_START	INT = NULL,
	@REAL_END	INT = NULL
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

		IF @SERVICE IS NOT NULL
			SET @MANAGER = NULL

		IF @DISCOUNT = 0
		BEGIN
			SET @DISC_START = NULL
			SET @DISC_END = NULL
		END

		IF @FIXED = 0
		BEGIN
			SET @FIX_START = NULL
			SET @FIX_END = NULL
		END

		DECLARE @MONTH UNIQUEIDENTIFIER

		SELECT @MONTH = Common.PeriodCurrent(2)

		DECLARE @MONTH_DATE	SMALLDATETIME

		SELECT @MONTH_DATE = START
		FROM Common.Period
		WHERE ID = @MONTH

		SELECT
			ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, SystemTypeName,
			DISCOUNT,	DF_FIXED_PRICE, REAL_DISCOUNT
		FROM
			(
				SELECT
					ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, SystemTypeName,
					CASE WHEN DSS_REPORT = 0 THEN NULL ELSE CONVERT(INT, DF_DISCOUNT) END AS DISCOUNT,
					CASE WHEN DSS_REPORT = 0 THEN NULL ELSE DF_FIXED_PRICE END AS DF_FIXED_PRICE,
					CASE
						WHEN DSS_REPORT = 0 THEN 100
						WHEN (ISNULL(DF_FIXED_PRICE, 0) <> 0) THEN
							CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DF_FIXED_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2))
						WHEN DF_ID_PRICE = 6 THEN CONVERT(DECIMAL(8, 2), ROUND((100 * (ROUND(PRICE * COEF, RND) - DEPO_PRICE) / NULLIF(ROUND(PRICE * COEF, RND), 0)), 2))
						WHEN ISNULL(DF_DISCOUNT, 0) <> 0 THEN DF_DISCOUNT
						ELSE 0
					END AS REAL_DISCOUNT, SystemOrder, DISTR, COMP
				FROM
					(
						SELECT
							ClientID, ClientFullName, ManagerName, ServiceName, DistrStr, SystemTypeName, DF_DISCOUNT, DF_FIXED_PRICE,
							DF_ID_PRICE, DSS_REPORT,
							dbo.DistrCoef(SystemID, DistrTypeID, SystemTypeName, @MONTH_DATE) AS COEF,
							dbo.DistrCoef(SystemID, DistrTypeID, SystemTypeName, @MONTH_DATE) AS RND,
							PRICE, DEPO_PRICE, SystemOrder, DISTR, COMP
						FROM
							dbo.ClientView a WITH(NOEXPAND)
							INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.ClientID = b.ID_CLIENT
							INNER JOIN dbo.DBFDistrFinancingView e ON SYS_REG_NAME = b.SystemBaseName
																		AND DIS_NUM = b.DISTR
																		AND DIS_COMP_NUM = b.COMP
							INNER JOIN Price.SystemPrice g ON ID_SYSTEM = SystemID AND g.ID_MONTH = @MONTH
						WHERE b.DS_REG = 0
							AND (a.ServiceID = @SERVICE OR @SERVICE IS NULL)
							AND (a.ManagerID = @MANAGER OR @MANAGER IS NULL)
							AND (b.SystemID = @SYSTEM OR @SYSTEM IS NULL)
							AND (@DISCOUNT = 0 OR @DISCOUNT = 1 AND ISNULL(DF_DISCOUNT, 0) <> 0)
							AND (@FIXED = 0 OR @FIXED = 1 AND ISNULL(DF_FIXED_PRICE, 0) <> 0)
							AND (DF_DISCOUNT >= @DISC_START OR @DISC_START IS NULL)
							AND (DF_DISCOUNT <= @DISC_END OR @DISC_END IS NULL)
							AND (DF_FIXED_PRICE >= @FIX_START OR @FIX_START IS NULL)
							AND (DF_FIXED_PRICE <= @FIX_END OR @FIX_END IS NULL)
							AND (SystemTypeID = @TYPE OR @TYPE IS NULL)
					) AS o_O
			) AS o_O
		WHERE (REAL_DISCOUNT >= @REAL_START OR @REAL_START IS NULL)
			AND (REAL_DISCOUNT <= @REAL_END OR @REAL_END IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, DISTR, COMP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISCOUNT_DBF_FILTER] TO rl_discount_dbf_filter;
GO
