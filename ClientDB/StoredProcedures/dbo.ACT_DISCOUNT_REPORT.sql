USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_DISCOUNT_REPORT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_DISCOUNT_REPORT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_DISCOUNT_REPORT]
	@MONTH		UNIQUEIDENTIFIER,
	@NET		NVARCHAR(MAX),
	@TYPE		NVARCHAR(MAX),
	@DSTART		DECIMAL(8,4),
	@DFINISH	DECIMAL(8,4)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@DATE			SmallDateTime,
		@TaxRate		Decimal(8, 4);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SELECT @DATE = START
		FROM [Common].[Period]
		WHERE ID = @MONTH;

		SELECT @TaxRate = TOTAL_RATE
		FROM Common.TaxDefaultSelect(@DATE);

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr

		CREATE TABLE #distr
		(
			SYS_REG		NVARCHAR(32),
			HST			INT,
			ID_SYSTEM	INT,
			DISTR		INT,
			COMP		INT,
			ID_NET		INT,
			NET			NVARCHAR(64),
			ID_TYPE		INT,
			ACT			MONEY,
			PRICE		MONEY,
			DISCOUNT	DECIMAL(8,4)
		);

		INSERT INTO #distr(SYS_REG, HST, ID_SYSTEM, DISTR, COMP, ACT)
		SELECT a.SYS_REG_NAME, b.HostID, b.SystemID, DIS_NUM, DIS_COMP_NUM, AD_TOTAL_PRICE
		FROM dbo.DBFActView a
		INNER JOIN dbo.SystemTable b ON a.SYS_REG_NAME = b.SystemBaseName
		WHERE PR_DATE = @DATE;

		UPDATE a SET
			PRICE	= ROUND(ROUND(c.PRICE * dbo.DistrCoef(a.ID_SYSTEM, NT_ID_MASTER, SystemTypeName, @DATE), dbo.DistrCoefRound(a.ID_SYSTEM, NT_ID_MASTER, SystemTypeName, @DATE)) * @TaxRate, 2),
			NET		= NT_SHORT,
			ID_NET	= NT_ID,
			ID_TYPE = SST_ID
		FROM #distr						AS A
		INNER JOIN dbo.DBFPeriodRegView AS B ON A.SYS_REG = B.SYS_REG_NAME AND A.DISTR = B.REG_DISTR_NUM AND A.COMP = B.REG_COMP_NUM AND B.PR_DATE = @DATE
		INNER JOIN [Price].[Systems:Price@Get](@DATE) AS C ON C.System_Id = A.ID_SYSTEM
		INNER JOIN Din.SystemType ON SST_REG = b.SST_NAME
		INNER JOIN dbo.SystemTypeTable ON SystemTypeID = SST_ID_MASTER
		INNER JOIN Din.NetType ON NT_TECH = SNC_TECH AND NT_NET = SNC_NET_COUNT;

		UPDATE #distr
		SET DISCOUNT = ROUND((PRICE - ACT) / PRICE * 100, 2)

		SELECT ClientID, ManagerName, ServiceName, ClientFullName, DistrStr, SST_SHORT AS SystemTypeName, NET, ACT, PRICE, DISCOUNT
		FROM #distr a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON HST = HostID AND a.DISTR = b.DISTR AND a.COMP = b.COMP
		INNER JOIN dbo.ClientView c WITH(NOEXPAND) ON c.ClientID = b.ID_CLIENT
		INNER JOIN Din.SystemType d ON d.SST_ID = a.ID_TYPE
		WHERE	(@NET IS NULL OR ID_NET IN (SELECT ID FROM dbo.TableIDFromXML(@NET)))
			AND (@TYPE IS NULL OR ID_TYPE IN (SELECT ID FROM dbo.TableIDFromXML(@TYPE)))
			AND (DISCOUNT >= @DSTART OR @DSTART IS NULL)
			AND (DISCOUNT <= @DFINISH OR @DFINISH IS NULL)
		ORDER BY ManagerName, ServiceName, ClientFullName, SystemOrder, a.DISTR, a.COMP;

		IF OBJECT_ID('tempdb..#distr') IS NOT NULL
			DROP TABLE #distr;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_DISCOUNT_REPORT] TO rl_report_act_discount;
GO
