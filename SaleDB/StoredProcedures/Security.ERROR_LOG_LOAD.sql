USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ERROR_LOG_LOAD]
	@TEXT	NVARCHAR(MAX)
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
		IF EXISTS(SELECT * FROM Security.ErrorText WHERE HOST = HOST_NAME())
			UPDATE Security.ErrorText
			SET TEXT = @TEXT,
				DATE = GETDATE()
			WHERE HOST = HOST_NAME()
		ELSE
			INSERT INTO Security.ErrorText(TEXT)
				VALUES(@TEXT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END

GO
GRANT EXECUTE ON [Security].[ERROR_LOG_LOAD] TO public;
GO