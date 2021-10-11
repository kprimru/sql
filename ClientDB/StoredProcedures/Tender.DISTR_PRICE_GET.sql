USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[DISTR_PRICE_GET]
	@LIST		NVARCHAR(MAX),
	@TYPE		TINYINT,
	@MONTH		UNIQUEIDENTIFIER,
	@DISCOUNT	DECIMAL(8, 4),
	@INFLATION	DECIMAL(8, 4),
	@SPREAD		MONEY
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

		DECLARE @XML XML

		SET @XML = CAST(@LIST AS XML)

		IF @TYPE = 1
			SELECT ID, PRICE
			FROM
				(
					SELECT
						a.ID,
						CONVERT(MONEY, ROUND(PRICE * c.COEF * (100 - @DISCOUNT) / 100 * (1 + @INFLATION / 100.0), 0)) AS PRICE
					FROM
						(
							SELECT 
								c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
								c.value('(@sys)', 'INT') AS SYS_ID,
								c.value('(@net)', 'INT') AS NET_ID
							FROM @xml.nodes('/root/item') AS a(c)
						) AS a
						INNER JOIN dbo.SystemTable b ON a.SYS_ID = b.SystemID
						INNER JOIN dbo.DistrTypeCoef c ON c.ID_NET = a.NET_ID AND c.ID_MONTH = @MONTH
						INNER JOIN Price.SystemPrice d ON ID_SYSTEM = SYS_ID
					WHERE d.ID_MONTH = @MONTH
				) AS o_O
		ELSE
			SELECT ID, PRICE
			FROM
				(
					SELECT 
						c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID,
						c.value('(@sys)', 'INT') AS SYS_ID,
						c.value('(@net)', 'INT') AS NET_ID
					FROM @xml.nodes('/root/item') AS a(c)
				) AS a
				INNER JOIN Tender.PriceSplit(@LIST, @MONTH, @SPREAD) b ON a.SYS_ID = b.SystemID AND a.NET_ID = b.DistrTypeID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Tender].[DISTR_PRICE_GET] TO rl_tender_u;
GO
