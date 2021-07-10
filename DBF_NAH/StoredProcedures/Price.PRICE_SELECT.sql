USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[PRICE_SELECT]
	@PERIOD	SMALLINT,
	@GROUP	VARCHAR(50) = NULL
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
		/*
		SET @SQL = N'
		SELECT PT_ID, PT_NAME, PT_ORDER, SST_ID, SST_CAPTION, '

		SELECT @SQL = @SQL + '
			(
				SELECT PS_PRICE
				FROM Price.PriceSystem
				WHERE PS_ID_PERIOD = @PERIOD
					AND PS_ID_SYSTEM = @SYSTEM
					AND PS_ID_PRICE = PT_ID
					AND PS_ID_TYPE = SST_ID
					AND PS_ID_NET = ''' + CONVERT(NVARCHAR(32), NT_ID) + '''
			) AS ''NET' + CONVERT(NVARCHAR(32), NT_ID) + ''','
		FROM dbo.NetType
		ORDER BY NT_NET, NT_TECH



		SET @SQL = @SQL + N'
		FROM
			Price.PriceType
			CROSS JOIN dbo.SystemTypeTable
			CROSS JOIN dbo.NetType
		ORDER BY PT_ORDER, ISNULL(SST_SORDER, 99999), NT_NET, NT_TECH'
		*/
		SET @SQL = N'
		SELECT SYS_ID, SYS_SHORT_NAME,'

		SELECT @SQL = @SQL + N'
			(
				SELECT PS_PRICE
				FROM Price.PriceSystem
				WHERE PS_ID_PERIOD = @PERIOD
					AND PS_ID_SYSTEM = SYS_ID
					AND PS_ID_PRICE = ''' + CONVERT(NVARCHAR(32), PT_ID) + '''
					AND PS_ID_TYPE = ''' + CONVERT(NVARCHAR(32), SST_ID) + '''
					AND PS_ID_NET = ''' + CONVERT(NVARCHAR(32), NT_ID) + '''
			) AS [' + PT_SHORT + '|' + NT_SHORT + '],'
		FROM
			Price.PriceType
			CROSS JOIN dbo.SystemTypeTable
			CROSS JOIN dbo.NetType
		WHERE SST_NAME = 'USR'
			AND (PT_GROUP = @GROUP OR @GROUP IS NULL)
		ORDER BY PT_ORDER, ISNULL(SST_SORDER, 99999), NT_NET, NT_TECH

		SET @SQL = LEFT(@SQL, LEN(@SQL) - 1)
		SET @SQL = @SQL + N'
		FROM dbo.SystemTable
		WHERE SYS_ID_SO = 1
		ORDER BY SYS_ORDER'

		--PRINT @SQL
		EXEC sp_executesql @SQL, N'@PERIOD SMALLINT', @PERIOD

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Price].[PRICE_SELECT] TO rl_price_w;
GO