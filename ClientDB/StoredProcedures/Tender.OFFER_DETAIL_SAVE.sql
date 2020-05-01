USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Tender].[OFFER_DETAIL_SAVE]
	@OFFER		UNIQUEIDENTIFIER,
	@ID_CLIENT	INT,
	@CLIENT		NVARCHAR(256),
	@ADDRESS	NVARCHAR(2048),
	@SYS		INT,
	@SYS_OLD	INT,
	@DISTR		NVARCHAR(64),
	@NET		INT,
	@NET_OLD	INT,
	@DBASE		MONEY,
	@D			MONEY,
	@EBASE		MONEY,
	@E			MONEY,
	@ABASE		MONEY,
	@A			MONEY,
	@SBASE		MONEY,
	@S			MONEY,
	@STOTAL		MONEY,
	@MON_CNT	SMALLINT
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

		INSERT INTO Tender.OfferDetail(ID_OFFER, ID_CLIENT, CLIENT, ADDRESS, ID_SYSTEM, ID_OLD_SYSTEM, DISTR, ID_NET, ID_OLD_NET, DELIVERY_BASE, DELIVERY, EXCHANGE_BASE, EXCHANGE, ACTUAL_BASE, ACTUAL, SUPPORT_BASE, SUPPORT, SUPPORT_TOTAL, MON_CNT)
			VALUES(@OFFER, @ID_CLIENT, @CLIENT, @ADDRESS, @SYS,	@SYS_OLD, @DISTR, @NET, @NET_OLD, @DBASE, @D, @EBASE, @E, @ABASE, @A, @SBASE, @S, @STOTAL, @MON_CNT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [Tender].[OFFER_DETAIL_SAVE] TO rl_tender_offer_u;
GRANT EXECUTE ON [Tender].[OFFER_DETAIL_SAVE] TO rl_tender_u;
GO