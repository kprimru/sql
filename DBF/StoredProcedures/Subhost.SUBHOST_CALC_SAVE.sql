USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[SUBHOST_CALC_SAVE]
	@SH_ID	SMALLINT,
	@PR_ID	SMALLINT,	
	@PAP_COUNT	INT,
	@PAP_PRICE	MONEY,
	@DELIVERY	MONEY,
	@TRAFFIC	MONEY,	
	@DIU		MONEY,
	@KBU		DECIMAL(8, 4),
	@TOTAL		MONEY,
	@TSTUDY		MONEY,
	@INV_DATE	SMALLDATETIME,
	@INV_NUM	VARCHAR(50),
	@INV_SDATE	SMALLDATETIME,
	@INV_SNUM	VARCHAR(50),
	@CLOSED		BIT
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

		UPDATE Subhost.SubhostCalc
		SET SHC_DELIVERY = @DELIVERY,
			SHC_PAPPER_COUNT = @PAP_COUNT,
			SHC_PAPPER_PRICE = @PAP_PRICE,
			SHC_TRAFFIC = @TRAFFIC,		
			SHC_DIU = @DIU,
			SHC_KBU = @KBU,
			SHC_TOTAL = @TOTAL,
			SHC_TOTAL_STUDY = @TSTUDY,
			SHC_INV_DATE = @INV_DATE,
			SHC_INV_NUM = @INV_NUM,
			SHC_INV_STUDY_DATE = @INV_SDATE,
			SHC_INV_STUDY_NUM = @INV_SNUM
		WHERE SHC_ID_SUBHOST = @SH_ID AND SHC_ID_PERIOD = @PR_ID

		IF @@ROWCOUNT = 0
			INSERT INTO Subhost.SubhostCalc(
					SHC_ID_SUBHOST, SHC_ID_PERIOD, SHC_DELIVERY, SHC_PAPPER_COUNT, SHC_PAPPER_PRICE, 
					SHC_TRAFFIC, SHC_DIU, SHC_KBU, SHC_TOTAL, SHC_TOTAL_STUDY,
					SHC_INV_DATE, SHC_INV_NUM, SHC_INV_STUDY_DATE, SHC_INV_STUDY_NUM, SHC_CLOSED
				)
				VALUES(
					@SH_ID, @PR_ID, @DELIVERY, @PAP_COUNT, @PAP_PRICE, @TRAFFIC, @DIU, @KBU, @TOTAL, @TSTUDY,
					@INV_DATE, @INV_NUM, @INV_SDATE, @INV_SNUM, @CLOSED
					)
					
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Subhost].[SUBHOST_CALC_SAVE] TO rl_subhost_calc;
GO