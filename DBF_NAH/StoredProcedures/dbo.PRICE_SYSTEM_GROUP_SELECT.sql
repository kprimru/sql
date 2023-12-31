USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/
ALTER PROCEDURE [dbo].[PRICE_SYSTEM_GROUP_SELECT]
	@group SMALLINT,
	@period SMALLINT
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

		DECLARE @sql NVARCHAR(MAX)

		SET @sql =
		'
		SELECT DISTINCT ''�������'' AS IS_SYS, SYS_ID, SYS_ORDER, PR_ID, SYS_SHORT_NAME
		'

		DECLARE @tp SMALLINT

		DECLARE TP CURSOR LOCAL FOR
			SELECT PT_ID
			FROM dbo.PriceTypeTable
			WHERE PT_ID_GROUP = @group
			ORDER BY PT_ID
		OPEN TP

		FETCH NEXT FROM TP INTO @tp

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = @sql + ',(
			SELECT PS_PRICE
			FROM dbo.PriceSystemTable b
			WHERE a.PS_ID_SYSTEM = b.PS_ID_SYSTEM
				AND a.PS_ID_PERIOD = b.PS_ID_PERIOD
				AND b.PS_ID_TYPE = ' + CONVERT(VARCHAR, @tp) + '
		) AS PS_PRICE_' + CONVERT(VARCHAR, @tp) + ',CONVERT(BIT,
			(
				SELECT COUNT(*)
				FROM dbo.PriceDepend
				WHERE PD_ID_PERIOD = PS_ID_PERIOD
					AND PD_ID_TYPE = ' + CONVERT(VARCHAR(20), @tp) + '
			)
			) AS PS_ENABLE_' + CONVERT(VARCHAR, @tp)


			FETCH NEXT FROM TP INTO @tp
		END

		CLOSE TP
		DEALLOCATE TP

		--SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SELECT @sql = @sql + '
		FROM 
			dbo.PriceSystemTable a INNER JOIN
			dbo.PeriodTable ON PR_ID = PS_ID_PERIOD INNER JOIN
			dbo.SystemTable ON SYS_ID = PS_ID_SYSTEM INNER JOIN
			dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
		WHERE PR_ID = ' + CONVERT(VARCHAR, @period) +
			' AND PT_ID_GROUP = ' + CONVERT(VARCHAR, @group) + '
		UNION ALL'


		SET @sql = @sql +
		'
		SELECT DISTINCT ''���.������'' AS IS_SYS, PGD_ID, 9999999 AS SYS_ORDER, PR_ID, PGD_NAME
		'

		--DECLARE @tp SMALLINT

		DECLARE TP CURSOR LOCAL FOR
			SELECT PT_ID
			FROM dbo.PriceTypeTable
			WHERE PT_ID_GROUP = @group
			ORDER BY PT_ID
		OPEN TP

		FETCH NEXT FROM TP INTO @tp

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = @sql + ',(
			SELECT PS_PRICE
			FROM dbo.PriceSystemTable b
			WHERE a.PS_ID_PGD = b.PS_ID_PGD
				AND a.PS_ID_PERIOD = b.PS_ID_PERIOD
				AND b.PS_ID_TYPE = ' + CONVERT(VARCHAR, @tp) + '
		) AS PS_PRICE_' + CONVERT(VARCHAR, @tp) +',CONVERT(BIT,0)
			AS PS_ENABLE_' + CONVERT(VARCHAR, @tp)

			FETCH NEXT FROM TP INTO @tp
		END

		CLOSE TP
		DEALLOCATE TP

		--SET @sql = LEFT(@sql, LEN(@sql) - 1)

		SELECT @sql = @sql + '
		FROM 
			dbo.PriceSystemTable a INNER JOIN
			dbo.PeriodTable ON PR_ID = PS_ID_PERIOD INNER JOIN
			dbo.PriceGoodTable ON PGD_ID = PS_ID_PGD INNER JOIN
			dbo.PriceTypeTable ON PT_ID = PS_ID_TYPE
		WHERE PR_ID = ' + CONVERT(VARCHAR, @period) +
			' AND PT_ID_GROUP = ' + CONVERT(VARCHAR, @group) + '
			AND PGD_ACTIVE = 1
		ORDER BY SYS_ORDER'

		EXEC (@sql)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[PRICE_SYSTEM_GROUP_SELECT] TO rl_price_val_r;
GO
