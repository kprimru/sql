USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[ACTION_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[ACTION_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[ACTION_DELETE]
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

	DELETE
	FROM Price.Action
	WHERE ID = @ID
END

GO
