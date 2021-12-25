USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_LOGON]
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT,
	@PERS	UNIQUEIDENTIFIER = NULL OUTPUT,
	@NAME	NVARCHAR(128) = NULL OUTPUT,
	@ORG	NVARCHAR(128) = NULL OUTPUT,
	@MONTH	UNIQUEIDENTIFIER = NULL OUTPUT,
	@MON_PRICE	UNIQUEIDENTIFIER = NULL OUTPUT,
	@MET_DELTA	INT = NULL OUTPUT,
	@STATUS_COLOR INT = NULL OUTPUT
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
		EXEC [Security].[USER_ID] @ID OUTPUT
		EXEC Personal.PERSONAL_ID @PERS OUTPUT, @NAME OUTPUT
		EXEC Common.GLOBAL_SETTING_GET N'ORG_NAME', @ORG OUTPUT
		EXEC Common.GLOBAL_SETTING_GET N'MEETING_DELTA', @MET_DELTA OUTPUT
		EXEC Common.GLOBAL_SETTING_GET N'STATUS_COLOR', @STATUS_COLOR OUTPUT

		SELECT @MONTH = ID
		FROM Common.Month
		WHERE GETDATE() BETWEEN DATE AND DATEADD(MONTH, 1, DATE)

		SELECT @MON_PRICE = ID
		FROM Common.Month
		WHERE DATE =
			(
				SELECT MAX(DATE)
				FROM
					Common.Month a
					INNER JOIN System.Price b ON a.ID = b.ID_MONTH
			)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_LOGON] TO public;
GO
