USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_USER_CREATE]
	@ID			UNIQUEIDENTIFIER,
	@LOGIN		NVARCHAR(128),
	@PASS		NVARCHAR(128),
	@ROLE		UNIQUEIDENTIFIER
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
		DECLARE @SHORT NVARCHAR(128)

		SELECT @SHORT = SHORT
		FROM Personal.OfficePersonal
		WHERE ID = @ID

		UPDATE Personal.OfficePersonal
		SET LOGIN	=	@LOGIN,
			PASS	=	@PASS
		WHERE ID = @ID

		IF @LOGIN IS NOT NULL AND @PASS IS NOT NULL
			EXEC Security.USER_CREATE 2, @LOGIN, @SHORT, @PASS, @ROLE

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_USER_CREATE] TO rl_user_w;
GO
