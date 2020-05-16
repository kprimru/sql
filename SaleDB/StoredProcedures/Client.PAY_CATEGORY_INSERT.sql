USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[PAY_CATEGORY_INSERT]
	@NAME	NVARCHAR(128),
	@SHORT	NVARCHAR(64),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

	DECLARE @TBL TABLE
		(
			ID	UNIQUEIDENTIFIER
		)

	BEGIN TRY
		INSERT INTO Client.PayCategory(NAME, SHORT, GR, ORD)
			OUTPUT inserted.ID INTO @TBL(ID)
			SELECT @NAME, @SHORT, @SHORT, (SELECT MAX(ORD) FROM Client.PayCategory) + 10

		SELECT @ID = ID FROM @TBL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[PAY_CATEGORY_INSERT] TO rl_pay_category_w;
GO