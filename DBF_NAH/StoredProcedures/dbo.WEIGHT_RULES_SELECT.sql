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
ALTER PROCEDURE [dbo].[WEIGHT_RULES_SELECT]
	@PR_ID		SMALLINT,
	@SYS_ID		VARCHAR(MAX) = NULL,
	@SST_ID		VARCHAR(MAX) = NULL,
	@NET_ID		VARCHAR(MAX) = NULL,
	@RES_CNT	INT = NULL OUTPUT,
	@IS_EQUAL	BIT = NULL OUTPUT
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
			SYS_ID		SMALLINT PRIMARY KEY,
			SYS_SHORT	VARCHAR(50),
			SYS_ORDER	INT
		)

		DECLARE @SYS_TYPE TABLE
		(
			SST_ID		SMALLINT PRIMARY KEY,
			SST_SHORT	VARCHAR(50),
			SST_ORDER	INT
		)

		DECLARE @NET	TABLE
		(
			SNC_ID		SMALLINT,
			SNC_SHORT	VARCHAR(50),
			SNC_ORDER	INT
		)

		INSERT INTO @SYSTEM
			SELECT SYS_ID, SYS_SHORT_NAME, SYS_ORDER
			FROM dbo.SystemTable
			WHERE @SYS_ID IS NULL OR SYS_ID IN (SELECT Item FROM dbo.GET_TABLE_FROM_LIST(@SYS_ID, ','))

		INSERT INTO @SYS_TYPE
			SELECT SST_ID, SST_CAPTION, SST_ORDER
			FROM dbo.SystemTypeTable
			WHERE @SST_ID IS NULL OR SST_ID IN (SELECT Item FROM dbo.GET_TABLE_FROM_LIST(@SST_ID, ','))

		INSERT INTO @NET
			SELECT SNC_ID, SNC_SHORT, ROW_NUMBER() OVER(ORDER BY SNC_TECH, SNC_NET_COUNT)
			FROM dbo.SystemNetCountTable
			WHERE @NET_ID IS NULL OR SNC_ID IN (SELECT Item FROM dbo.GET_TABLE_FROM_LIST(@NET_ID, ','))

		DECLARE @WEIGHT TABLE
		(
			ID			INT,
			SYS_ID		SMALLINT,
			SST_ID		SMALLINT,
			SNC_ID		SMALLINT,
			ITEM_NAME	VARCHAR(100),
			ITEM_ORDER	INT,
			WEIGHT		DECIMAL(8,4),
			PRIMARY KEY CLUSTERED (SYS_ID, SST_ID, SNC_ID)
		)

		INSERT INTO @WEIGHT
		SELECT ID, SYS_ID, SST_ID, SNC_ID, SST_SHORT + ' :: ' + SYS_SHORT + ' :: ' + SNC_SHORT, SNC_ORDER, WEIGHT
		FROM dbo.WeightRules
		INNER JOIN @SYSTEM ON ID_SYSTEM = SYS_ID
		INNER JOIN @SYS_TYPE ON ID_TYPE = SST_ID
		INNER JOIN @NET ON ID_NET = SNC_ID
		WHERE ID_PERIOD = @PR_ID

		SELECT
			'R:<' + Convert(VarChar(20), SST_ID) + ':' + Convert(VarChar(20), SYS_ID) + ':' + Convert(VarChar(20), SNC_ID) + '>' AS ROOT_ID,
			'R:<' + Convert(VarChar(20), SST_ID) + ':' + Convert(VarChar(20), SYS_ID) + '>' AS PARENT_ID,
			ID, SYS_ID, SST_ID, SNC_ID, ITEM_NAME, ITEM_ORDER, WEIGHT, CONVERT(VARCHAR(512), WEIGHT) AS WEIGHT_STR
		FROM @WEIGHT

		UNION ALL

		SELECT DISTINCT
			'R:<' + Convert(VarChar(20), W.SST_ID) + ':' + Convert(VarChar(20), W.SYS_ID) + '>' AS ROOT_ID,
			'R:<' + Convert(VarChar(20), W.SST_ID) + '>' AS PARENT_ID,
			NULL, W.SYS_ID, W.SST_ID, NULL, SST_SHORT + ' :: ' + SYS_SHORT, SYS_ORDER, NULL,
			REVERSE(STUFF(REVERSE((
				SELECT CONVERT(VARCHAR(512), WEIGHT) + ' / '
				FROM
					(
						SELECT DISTINCT WEIGHT
						FROM @WEIGHT Z
						WHERE Z.SYS_ID = W.SYS_ID AND Z.SST_ID = W.SST_ID
					) AS o_O
				ORDER BY WEIGHT FOR XML PATH('')
			)), 1, 3, ''))
		FROM @WEIGHT W
		INNER JOIN @SYSTEM S ON W.SYS_ID = S.SYS_ID
		INNER JOIN @SYS_TYPE T ON W.SST_ID = T.SST_ID

		UNION ALL

		SELECT DISTINCT
			'R:<' + Convert(VarChar(20), W.SST_ID) + '>' AS ROOT_ID,
			NULL AS PARENT_ID,
			NULL, NULL, W.SST_ID, NULL, SST_SHORT, SST_ORDER, NULL,
			REVERSE(STUFF(REVERSE((
				SELECT CONVERT(VARCHAR(512), WEIGHT) + ' / '
				FROM
					(
						SELECT DISTINCT WEIGHT
						FROM @WEIGHT Z
						WHERE Z.SST_ID = W.SST_ID
					) AS o_O
				ORDER BY WEIGHT FOR XML PATH('')
			)), 1, 3, ''))
		FROM @WEIGHT W
		INNER JOIN @SYS_TYPE T ON W.SST_ID = T.SST_ID
		ORDER BY ITEM_ORDER

		SELECT @RES_CNT = COUNT(*)
		FROM @WEIGHT

		IF (SELECT COUNT(DISTINCT WEIGHT) FROM @WEIGHT) = 1
			SET @IS_EQUAL = 1
		ELSE
			SET @IS_EQUAL = 0

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO