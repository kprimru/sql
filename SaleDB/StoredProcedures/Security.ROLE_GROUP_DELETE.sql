USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Security].[ROLE_GROUP_DELETE]
	@ID			UNIQUEIDENTIFIER
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
		DECLARE @NAME NVARCHAR(256)

		SELECT @NAME = NAME
		FROM Security.RoleGroup
		WHERE ID = @ID

		DELETE
		FROM Security.RoleGroup
		WHERE ID = @ID

		IF ISNULL(@NAME, N'') <> N''
			EXEC ('DROP ROLE [' + @NAME + ']')

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Security].[ROLE_GROUP_DELETE] TO rl_role_group_d;
GO
