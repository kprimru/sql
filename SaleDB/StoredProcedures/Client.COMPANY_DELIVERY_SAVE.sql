USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DELIVERY_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@COMPANY	UNIQUEIDENTIFIER,
	@FIO		NVARCHAR(256),
	@POS		NVARCHAR(256),
	@EMAIL		NVARCHAR(256),
	@DATE		SMALLDATETIME,
	@PLAN_DATE	SMALLDATETIME,
	@OFFER		NVARCHAR(256),
	@STATE		SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	IF @ID IS NULL
		INSERT INTO Client.CompanyDelivery(ID_COMPANY, FIO, POS, EMAIL, DATE, PLAN_DATE, OFFER, STATE)
			VALUES(@COMPANY, @FIO, @POS, @EMAIL, @DATE, @PLAN_DATE, @OFFER, @STATE)
	ELSE
		UPDATE Client.CompanyDelivery
		SET FIO			=	@FIO,
			POS			=	@POS,
			EMAIL		=	@EMAIL,
			DATE		=	@DATE,
			PLAN_DATE	=	@PLAN_DATE,
			OFFER		=	@OFFER,
			STATE		=	@STATE
		WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DELIVERY_SAVE] TO rl_delivery_w;
GO