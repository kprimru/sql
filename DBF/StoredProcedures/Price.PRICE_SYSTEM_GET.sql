USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[PRICE_SYSTEM_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[PRICE_SYSTEM_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[PRICE_SYSTEM_GET]
	@PERIOD	SMALLINT,
	@SYSTEM	SMALLINT,
	@GROUP	NVARCHAR(64) = NULL
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

		DECLARE @SQL NVARCHAR(MAX)

		SET @SQL = N'
		SELECT
			PT_ID, SST_ID, SST_CAPTION,
			CONVERT(NVARCHAR(64), PT_ORDER) + '' '' + PT_NAME AS PT_GR_ORDER,
			'

		SELECT @SQL = @SQL + '
			ISNULL((
				SELECT PS_PRICE
				FROM Price.PriceSystem
				WHERE PS_ID_PERIOD = @PERIOD
					AND PS_ID_SYSTEM = @SYSTEM
					AND PS_ID_PRICE = PT_ID
					AND PS_ID_TYPE = SST_ID
					AND PS_ID_NET = ''' + CONVERT(NVARCHAR(32), NT_ID) + '''
			), 0) AS ''NET' + CONVERT(NVARCHAR(32), NT_ID) + ''','
		FROM dbo.NetType
		ORDER BY NT_NET, NT_TECH

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)

		SET @SQL = @SQL + N'
		FROM
			Price.PriceType
			CROSS JOIN dbo.SystemTypeTable
		WHERE PT_GROUP = @GROUP OR @GROUP IS NULL
		ORDER BY PT_ORDER, ISNULL(SST_SORDER, 99999)'

		--PRINT @SQL
		EXEC sp_executesql @SQL, N'@PERIOD SMALLINT, @SYSTEM SMALLINT, @GROUP NVARCHAR(64)', @PERIOD, @SYSTEM, @GROUP

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Price].[PRICE_SYSTEM_GET] TO rl_price_w;
GO
