USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_KBU_SELECT]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT
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

		DECLARE @sql NVARCHAR(MAX)

		SET @sql =
		'
		SELECT
			SYS_ID, SYS_SHORT_NAME,
			(
				SELECT SK_KBU
				FROM Subhost.SubhostKbuTable
				WHERE SK_ID_PERIOD = @PR_ID
					AND SK_ID_HOST = @SH_ID
					AND SK_ID_SYSTEM = SYS_ID
			) AS SK_KBU
		'

		DECLARE @tp SMALLINT

		DECLARE TP CURSOR LOCAL FOR
			SELECT PT_ID
			FROM
				dbo.PriceTypeTable
				INNER JOIN dbo.PriceGroupTable ON PG_ID = PT_ID_GROUP
			WHERE PT_ID_GROUP IN (4, 5, 6, 7)
			ORDER BY PG_ORDER, PT_ORDER
		OPEN TP

		FETCH NEXT FROM TP INTO @tp

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = @sql + ',(
			SELECT SPS_PRICE
			FROM Subhost.SubhostPriceSystemTable
			WHERE SPS_ID_SYSTEM = SYS_ID
				AND SPS_ID_PERIOD = @PR_ID
				AND SPS_ID_HOST = @SH_ID
				AND SPS_ID_TYPE = ' + CONVERT(VARCHAR, @tp) + '
		) AS PS_PRICE_' + CONVERT(VARCHAR, @tp) +''

			FETCH NEXT FROM TP INTO @tp
		END

		CLOSE TP
		DEALLOCATE TP

		--SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SELECT @sql = @sql + '
		FROM dbo.SystemTable
		WHERE EXISTS
			(
				SELECT *
				FROM Subhost.SubhostKbuTable
				WHERE SK_ID_PERIOD = @PR_ID
					AND SK_ID_HOST = @SH_ID
					AND SK_ID_SYSTEM = SYS_ID
			) OR EXISTS
			(
				SELECT *
				FROM Subhost.SubhostPriceSystemTable
				WHERE SPS_ID_SYSTEM = SYS_ID
					AND SPS_ID_PERIOD = @PR_ID
					AND SPS_ID_HOST = @SH_ID
			)
		ORDER BY SYS_ORDER '

		EXEC sp_executesql @SQL, N'@PR_ID SMALLINT, @SH_ID SMALLINT', @PR_ID, @SH_ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_KBU_SELECT] TO rl_subhost_calc;
GO
