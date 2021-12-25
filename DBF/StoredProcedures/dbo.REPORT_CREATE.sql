USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  коллектив авторов
Описание:
*/
ALTER PROCEDURE [dbo].[REPORT_CREATE]
/*
1:
	REPORT_SYSTEM_SUBHOST
	:pStatus,
	:pSubhost,
	:pSystem, :pSystemType, :pSystemNet,
	:pTotal,
	--:pPeriodFirst, :pPeriodLast
2:
	REPORT_SYSTEM_NAME_HOST_NET
	:pStatus,
	:pSubhost,
	:pSystem, :pSystemType, :pSystemNet,
	:pTotalRic,
	:pTotal,
	:pPeriodFirst, :pPeriodLast
3:
	REPORT_NEW_SYSTEM
	:pSubhost,
	:pSystem, :pSystemType, :pSystemNet,
	:pTotal,
	:pPeriodFirst, :pPeriodLast
4:
	REPORT_NEW_SYSTEM_LIST
	:pSubhost,
	:pSystem, :pSystemType, :pSystemNet,
	:pPeriodFirst, :pPeriodLast
*/
	@reporttype	SMALLINT,
	@distrstats	VARCHAR(MAX),
	@subhosts VARCHAR(MAX),
	@systems VARCHAR(MAX),
	@systemtypes VARCHAR(MAX),
	@systemnets VARCHAR(MAX),
	@total SMALLINT,
	@totalric SMALLINT,
	@periods VARCHAR(MAX),
	@techtypes VARCHAR(MAX)
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

		------------------ Кол-во систем -------------------
		IF @reporttype = 1
			EXEC dbo.REPORT_SYSTEM_SUBHOST
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes, @total
		ELSE
		--------- Кол-во систем разной сетевитости ---------
		IF @reporttype = 2
			EXEC dbo.REPORT_SYSTEM_NAME_HOST_NET
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total, @totalric
		ELSE
		--------------- Кол-во новых систем  ---------------
		IF @reporttype = 3
			EXEC dbo.REPORT_NEW_SYSTEM
				@subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total
		ELSE
		--------------- Список новых систем ----------------
		IF @reporttype = 4
			EXEC dbo.REPORT_NEW_SYSTEM_LIST
				@subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes

		ELSE
		IF @reporttype = 5
		BEGIN
			SELECT TOP 1 @periods = Item FROM dbo.GET_TABLE_FROM_LIST(@periods, ',') INNER JOIN dbo.PeriodTable ON Item = PR_ID ORDER BY PR_DATE DESC
			EXEC dbo.REPORT_SYSTEM_SUBHOST_LIST
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes
		END
		ELSE
		IF @reporttype = 6
		BEGIN
			SELECT TOP 1 @periods = Item FROM dbo.GET_TABLE_FROM_LIST(@periods, ',') INNER JOIN dbo.PeriodTable ON Item = PR_ID ORDER BY PR_DATE DESC
			EXEC dbo.REPORT_SUBHOST_SYSTEM_LIST
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes
		END
		ELSE IF @reporttype = 7
		BEGIN
			EXEC dbo.REPORT_SYSTEM_NAME_HOST_NET_NEW
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total, @totalric
		END
		ELSE IF @reporttype = 9
		BEGIN
			EXEC dbo.REPORT_NEW_SYSTEM_WEIGHT
				@subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total
		END
		ELSE IF @reporttype = 10
		BEGIN
			EXEC dbo.REPORT_SYSTEM_NAME_HOST_NET_GROUP
				@distrstats, @subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total, @totalric
		END
		ELSE IF @reporttype = 11
		BEGIN
			EXEC dbo.REPORT_VKSP
				@periods
		END
		ELSE IF @reporttype = 12
			EXEC dbo.REPORT_NEW_SYSTEM_NEW
				@subhosts,
				@systems, @systemtypes, @systemnets,
				@periods, @techtypes,
				@total
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_CREATE] TO rl_reg_node_report_r;
GRANT EXECUTE ON [dbo].[REPORT_CREATE] TO rl_reg_report_r;
GO
