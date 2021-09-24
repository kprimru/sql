USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[CALL_DATE_CHANGE]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME
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

	BEGIN TRY
		IF @DATE IS NULL
			DELETE
			FROM Client.CallDate
			WHERE ID_COMPANY = @ID
		ELSE
		BEGIN
			UPDATE Client.CallDate
			SET DATE = @DATE
			WHERE ID_COMPANY = @ID

			IF @@ROWCOUNT = 0
				INSERT INTO Client.CallDate(ID_COMPANY, DATE)
					VALUES(@ID, @DATE)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[CALL_DATE_CHANGE] TO rl_company_call_date;
GO
