USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_KBU_SET]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,
	@SYS_ID	SMALLINT,
	@KBU	DECIMAL(8, 4),
	@PRICES	VARCHAR(MAX)
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

		IF @KBU IS NOT NULL
		BEGIN
			UPDATE Subhost.SubhostKbuTable
			SET SK_KBU = @KBU
			WHERE SK_ID_PERIOD = @PR_ID
				AND SK_ID_HOST = @SH_ID
				AND SK_ID_SYSTEM = @SYS_ID

			IF @@ROWCOUNT = 0
				INSERT INTO Subhost.SubhostKbuTable(SK_ID_PERIOD, SK_ID_HOST, SK_ID_SYSTEM, SK_KBU, SK_ACTIVE)
					VALUES(@PR_ID, @SH_ID, @SYS_ID, @KBU, 1)
		END
		ELSE
		BEGIN
			DELETE
			FROM Subhost.SubhostKbuTable
			WHERE SK_ID_PERIOD = @PR_ID
				AND SK_ID_HOST = @SH_ID
				AND SK_ID_SYSTEM = @SYS_ID
		END

		DECLARE @tprice TABLE
			(
				ID SMALLINT IDENTITY(1, 1),
				PS_VAL MONEY
			)

		SET @PRICES = REPLACE(@PRICES, ',', '.')

		INSERT INTO @tprice
			SELECT *
			FROM dbo.GET_MONEY_TABLE_FROM_LIST(@PRICES, ';')

		DECLARE PT CURSOR LOCAL FOR
			SELECT PT_ID
			FROM
				dbo.PriceTypeTable
				INNER JOIN dbo.PriceGroupTable ON PG_ID = PT_ID_GROUP
			WHERE PT_ID_GROUP IN (4, 5, 6, 7)
			ORDER BY PG_ORDER, PT_ORDER

		OPEN PT

		DECLARE @pt SMALLINT

		FETCH NEXT FROM PT INTO @pt

		DECLARE @ps SMALLINT

		SET @ps = 1

		DECLARE @PRICE MONEY

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @PRICE = PS_VAL
			FROM @tprice
			WHERE ID = @ps

			IF @PRICE <> 0
			BEGIN
				UPDATE Subhost.SubhostPriceSystemTable
				SET SPS_PRICE = @PRICE
				WHERE SPS_ID_PERIOD = @PR_ID
					AND SPS_ID_SYSTEM = @SYS_ID
					AND SPS_ID_HOST = @SH_ID
					AND SPS_ID_TYPE = @pt

				IF @@ROWCOUNT = 0
					INSERT INTO Subhost.SubhostPriceSystemTable(SPS_ID_SYSTEM, SPS_ID_PERIOD, SPS_ID_HOST, SPS_ID_TYPE, SPS_PRICE, SPS_ACTIVE)
						VALUES(@SYS_ID, @PR_ID, @SH_ID, @pt, @PRICE, 1)
			END
			ELSE
				DELETE
				FROM Subhost.SubhostPriceSystemTable
				WHERE SPS_ID_PERIOD = @PR_ID
					AND SPS_ID_HOST = @SH_ID
					AND SPS_ID_SYSTEM = @SYS_ID
					AND SPS_ID_TYPE = @pt

			SET @ps = @ps + 1

			FETCH NEXT FROM PT INTO @pt
		END

		CLOSE PT
		DEALLOCATE PT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_KBU_SET] TO rl_subhost_calc;
GO
