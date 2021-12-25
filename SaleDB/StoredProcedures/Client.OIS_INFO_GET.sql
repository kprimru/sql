USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[OIS_INFO_GET]
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

	SELECT *, (SELECT NAME FROM Client.Company z WHERE STATUS = 1 AND z.ID = a.ID_COMPANY) AS CO_NAME
	FROM Client.OISInfo a
	WHERE ID = @ID
END

GO
GRANT EXECUTE ON [Client].[OIS_INFO_GET] TO rl_client_ois_r;
GO
