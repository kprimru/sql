USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
јвтор:		  ƒенисов јлексей
ƒата создани€: 18.12.2008
ќписание:	  —делать копию указанного
               прейскуранта (тип-период) на
               указанный тип-период
*/

ALTER PROCEDURE [dbo].[PRICE_COPY]
	@sourcepriceid SMALLINT,
	@sourceperiodid SMALLINT,
	@destpriceid SMALLINT,
	@destperiodid SMALLINT,
	@coef DECIMAL(8, 4) = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		--≈сли в исходном прейскуранте ничего нет.

		DECLARE @error BIT

		IF OBJECT_ID('tempbd..#temp') IS NOT NULL
			DROP TABLE #temp

		CREATE TABLE #temp
			(
				ER_MSG VARCHAR(255)
			)

		SET @error = 0

		IF (
			SELECT COUNT(*)
			FROM dbo.PriceSystemTable
			WHERE
				PS_ID_PERIOD = @sourceperiodid AND
				PS_ID_TYPE = @sourcepriceid
			) = 0
		BEGIN
			SET @error = 1

			INSERT INTO #temp (ER_MSG)
			VALUES ('¬ исходном прейскуранте нет ни одной системы на указанный период')
		END

		/*
		IF (
			SELECT COUNT(*)
			FROM dbo.PriceSystemTable
			WHERE
				PS_ID_PERIOD = @destperiodid AND
				PS_ID_TYPE = @destpriceid
			) <> 0
		BEGIN
			SET @error = 1

			INSERT INTO #temp (ER_MSG)
			VALUES ('¬ указанном прейскуранте уже есть системы на указанный период')
		END
		*/

		IF @error = 0
		BEGIN
			--сделать копию количества документов на этот период
			--(если такие данные уже есть, то их пропускать)
			/*
			INSERT INTO dbo.PriceSystemHistoryTable (PSH_ID_PERIOD, PSH_ID_SYSTEM, PSH_DOC_COUNT)
				SELECT @destperiodid, PSH_ID_SYSTEM, PSH_DOC_COUNT
				FROM dbo.PriceSystemHistoryTable
				WHERE PSH_ID_PERIOD = @sourceperiodid AND
					NOT EXISTS (
								SELECT *
								FROM dbo.PriceSystemHistoryTable
								WHERE PSH_ID_PERIOD = @destperiodid
								)
			*/

			--скопировать данные систем в таблицу
			INSERT INTO dbo.PriceSystemTable (PS_ID_PERIOD, PS_ID_TYPE, PS_ID_SYSTEM, PS_PRICE)
				SELECT @destperiodid, @destpriceid, PS_ID_SYSTEM, CAST(ROUND(PS_PRICE * @coef, 0) AS MONEY)
				FROM dbo.PriceSystemTable a
				WHERE PS_ID_PERIOD = @sourceperiodid AND
					PS_ID_TYPE = @sourcepriceid
					AND NOT EXISTS
						(
							SELECT *
							FROM dbo.PriceSystemTable b
							WHERE PS_ID_PERIOD = @destperiodid AND
								PS_ID_TYPE = @destpriceid
								AND a.PS_ID_SYSTEM = b.PS_ID_SYSTEM
						)
		END
		ELSE
		BEGIN
			SELECT ER_MSG FROM #temp
		END

		DROP TABLE #temp

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_COPY] TO rl_price_copy;
GRANT EXECUTE ON [dbo].[PRICE_COPY] TO rl_price_list_w;
GO
