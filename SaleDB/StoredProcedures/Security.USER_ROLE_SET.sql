USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[USER_ROLE_SET]
	@USER	NVARCHAR(128),
	@ROLE	NVARCHAR(128),
	@CHECK	BIT
WITH EXECUTE AS OWNER
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
		IF @CHECK = 0
			EXEC sp_droprolemember @ROLE, @USER
		ELSE IF @CHECK = 1
			EXEC sp_addrolemember @ROLE, @USER

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[USER_ROLE_SET] TO rl_user_role_w;
GO