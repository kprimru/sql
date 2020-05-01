USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_RESULT_SAVE]
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

		DECLARE @stype TABLE
			(
				SST_ID SMALLINT, 
				SST_CAPTION VARCHAR(20), 
				SST_COEF BIT, 
				SST_KBU BIT, 
				SST_ORDER INT, 
				SST_COUNT SMALLINT
			)

		INSERT INTO @stype
			EXEC Subhost.SUBHOST_SYSTEM_TYPE_SELECT

		INSERT INTO Subhost.SubhostSystemType(SSST_ID_SUBHOST, SSST_ID_PERIOD, SSST_TYPE, SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_ORDER, SST_COUNT)
			SELECT @SH_ID, @PR_ID, 'DELIVERY', SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_ORDER, SST_COUNT
			FROM @stype

		DELETE FROM @stype
		
		INSERT INTO @stype
			EXEC Subhost.SUBHOST_SYSTEM_TYPE_SUPPORT_SELECT
		
		INSERT INTO Subhost.SubhostSystemType(SSST_ID_SUBHOST, SSST_ID_PERIOD, SSST_TYPE, SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_ORDER, SST_COUNT)
			SELECT @SH_ID, @PR_ID, 'SUPPORT', SST_ID, SST_CAPTION, SST_COEF, SST_KBU, SST_ORDER, SST_COUNT
			FROM @stype

		DECLARE @system	TABLE
			(
				SYS_ID	SMALLINT, 
				SYS_SHORT_NAME VARCHAR(50), 
				SYS_OLD VARCHAR(50), 
				SYS_NEW VARCHAR(50), 
				SYS_ORDER INT, 
				SYS_KBU DECIMAL(8, 4)
			)

		INSERT INTO @system
			EXEC Subhost.SUBHOST_SYSTEM_SELECT @SH_ID, @PR_ID
		
		INSERT INTO Subhost.SubhostSystem(SS_ID_PERIOD, SS_ID_SUBHOST, SYS_ID, SYS_SHORT_NAME, SYS_OLD, SYS_NEW, SYS_ORDER, SYS_KBU)
			SELECT @PR_ID, @SH_ID, SYS_ID, SYS_SHORT_NAME, SYS_OLD, SYS_NEW, SYS_ORDER, SYS_KBU
			FROM @system

		DECLARE @net TABLE
			(
				ID INT,
				TITLE VARCHAR(100),
				SN_ID SMALLINT,
				TT_ID SMALLINT,
				COEF DECIMAL(8, 4),
				COEF_OLD DECIMAL(8, 4),
				COEF_NEW DECIMAL(8, 4)
			)

		INSERT INTO @net 
			EXEC Subhost.SUBHOST_NET_COEF_GET

		INSERT INTO Subhost.SubhostNetType(SNT_ID_PERIOD, SNT_ID_SUBHOST, SNT_TYPE, ID, TITLE, SN_ID, TT_ID, COEF, COEF_OLD, COEF_NEW)
			SELECT @PR_ID, @SH_ID, 'DELIVERY', ID, TITLE, SN_ID, TT_ID, COEF, COEF_OLD, COEF_NEW
			FROM @net
			
		DELETE FROM @net
		
		INSERT INTO @net
			EXEC Subhost.SUBHOST_SUPPORT_NET_COEF_GET

		INSERT INTO Subhost.SubhostNetType(SNT_ID_PERIOD, SNT_ID_SUBHOST, SNT_TYPE, ID, TITLE, SN_ID, TT_ID, COEF, COEF_OLD, COEF_NEW)
			SELECT @PR_ID, @SH_ID, 'SUPPORT', ID, TITLE, SN_ID, TT_ID, COEF, COEF_OLD, COEF_NEW
			FROM @net

		DECLARE @distr TABLE
			(
				SST_ID	SMALLINT, 
				SYS_SHORT_NAME	VARCHAR(50), 
				TITLE	VARCHAR(50), 
				SYS_COUNT	SMALLINT
			)

		INSERT INTO @distr
			EXEC Subhost.SUBHOST_DELIVERY_SELECT @PR_ID, @SH_ID

		INSERT INTO Subhost.SubhostDistr(SD_ID_PERIOD, SD_ID_SUBHOST, SD_TYPE, SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT)
			SELECT @PR_ID, @SH_ID, 'DELIVERY', SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT
			FROM @distr

		DELETE FROM @distr

		INSERT INTO @distr
			EXEC Subhost.SUBHOST_SUPPORT_SELECT @PR_ID, @SH_ID

		INSERT INTO Subhost.SubhostDistr(SD_ID_PERIOD, SD_ID_SUBHOST, SD_TYPE, SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT)
			SELECT @PR_ID, @SH_ID, 'SUPPORT', SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT
			FROM @distr

		DELETE FROM @distr

		INSERT INTO @distr 
			EXEC Subhost.SUBHOST_SUPPORT_CONNECT_SELECT @PR_ID, @SH_ID

		INSERT INTO Subhost.SubhostDistr(SD_ID_PERIOD, SD_ID_SUBHOST, SD_TYPE, SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT)
			SELECT @PR_ID, @SH_ID, 'CONNECT', SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT
			FROM @distr

		DELETE FROM @distr

		INSERT INTO @distr 
			EXEC Subhost.SUBHOST_SUPPORT_COMPENSATION_SELECT @PR_ID, @SH_ID

		INSERT INTO Subhost.SubhostDistr(SD_ID_PERIOD, SD_ID_SUBHOST, SD_TYPE, SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT)
			SELECT @PR_ID, @SH_ID, 'COMPENSATION', SST_ID, SYS_SHORT_NAME, TITLE, SYS_COUNT
			FROM @distr
			
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
