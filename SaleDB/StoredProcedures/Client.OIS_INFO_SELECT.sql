USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[OIS_INFO_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[OIS_INFO_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[OIS_INFO_SELECT]
	@ID	UNIQUEIDENTIFIER
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

	SELECT *
	FROM Client.OISInfo
	WHERE ID_COMPANY = @ID
END

GO
GRANT EXECUTE ON [Client].[OIS_INFO_SELECT] TO rl_client_ois_r;
GO
