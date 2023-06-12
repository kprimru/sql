﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[WEIGHT_RULES_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[WEIGHT_RULES_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[WEIGHT_RULES_SAVE]
	@PR_ID		SMALLINT,
	@SYS_ID		VARCHAR(MAX),
	@SST_ID		VARCHAR(MAX),
	@NET_ID		VARCHAR(MAX),
	@WEIGHT		DECIMAL(8,4),
	@FURTHER	BIT
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

		DECLARE @SYSTEM TABLE
		(
			SYS_ID	SMALLINT PRIMARY KEY CLUSTERED
		)

		DECLARE @SYSTEM_TYPE TABLE
		(
			SST_ID	SMALLINT PRIMARY KEY CLUSTERED
		)

		DECLARE @NET TABLE
		(
			NET_ID	SMALLINT PRIMARY KEY CLUSTERED
		)

		DECLARE @PERIOD TABLE
		(
			PR_ID	SMALLINT PRIMARY KEY CLUSTERED
		)

		INSERT INTO @SYSTEM(SYS_ID)
		SELECT Item
		FROM dbo.GET_TABLE_FROM_LIST(@SYS_ID, ',')

		INSERT INTO @SYSTEM_TYPE(SST_ID)
		SELECT Item
		FROM dbo.GET_TABLE_FROM_LIST(@SST_ID, ',')

		INSERT INTO @NET(NET_ID)
		SELECT Item
		FROM dbo.GET_TABLE_FROM_LIST(@NET_ID, ',')

		INSERT INTO @PERIOD(PR_ID)
		SELECT @PR_ID
		UNION
		SELECT PR_ID
		FROM dbo.PeriodTable
		WHERE PR_DATE > (SELECT PR_DATE FROM dbo.PeriodTable WHERE PR_ID = @PR_ID)
			AND @FURTHER = 1

		UPDATE a
		SET WEIGHT = @WEIGHT
		FROM dbo.WeightRules a
		INNER JOIN @PERIOD ON ID_PERIOD = PR_ID
		INNER JOIN @SYSTEM ON ID_SYSTEM = SYS_ID
		INNER JOIN @SYSTEM_TYPE ON ID_TYPE = SST_ID
		INNER JOIN @NET ON ID_NET = NET_ID

		INSERT INTO dbo.WeightRules(ID_PERIOD, ID_SYSTEM, ID_TYPE, ID_NET, WEIGHT)
		SELECT PR_ID, SYS_ID, SST_ID, NET_ID, @WEIGHT
		FROM @PERIOD
		CROSS JOIN @SYSTEM
		CROSS JOIN @SYSTEM_TYPE
		CROSS JOIN @NET
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.WeightRules
				WHERE ID_PERIOD = PR_ID
					AND ID_SYSTEM = SYS_ID
					AND ID_TYPE = SST_ID
					AND ID_NET = NET_ID
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[WEIGHT_RULES_SAVE] TO rl_weight_rules;
GO
