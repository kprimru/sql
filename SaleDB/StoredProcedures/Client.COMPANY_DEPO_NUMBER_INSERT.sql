USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_DEPO_NUMBER_INSERT]
	@COMPANY_NUMBER	INT,
	@DEPO_NUMBER	INT,
	@STATUS			INT
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

    UPDATE
		Client.DepoNumbers
	SET
		COMPANY_NUMBER = @COMPANY_NUMBER,
		STATUS = @STATUS
	WHERE
		DEPO_NUM = @DEPO_NUMBER
END

GO
GRANT EXECUTE ON [Client].[COMPANY_DEPO_NUMBER_INSERT] TO gr_all;
GRANT EXECUTE ON [Client].[COMPANY_DEPO_NUMBER_INSERT] TO rl_company_depo_num;
GO