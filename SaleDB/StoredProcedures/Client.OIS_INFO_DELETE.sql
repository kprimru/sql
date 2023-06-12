USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[OIS_INFO_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[OIS_INFO_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[OIS_INFO_DELETE]
	@ID				UNIQUEIDENTIFIER
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

	DELETE
	FROM Client.OISInfo
	WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[OIS_INFO_DELETE] TO rl_client_ois_d;
GO
