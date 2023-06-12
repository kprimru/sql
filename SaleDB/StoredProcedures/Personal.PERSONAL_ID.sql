USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Personal].[PERSONAL_ID]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Personal].[PERSONAL_ID]  AS SELECT 1')
GO
ALTER PROCEDURE [Personal].[PERSONAL_ID]
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT,
	@NAME	NVARCHAR(128) = NULL OUTPUT
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
		SELECT @ID = ID, @NAME = SHORT
		FROM Personal.OfficePersonal
		WHERE UPPER(LOGIN) = UPPER(ORIGINAL_LOGIN())
			AND END_DATE IS NULL

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
