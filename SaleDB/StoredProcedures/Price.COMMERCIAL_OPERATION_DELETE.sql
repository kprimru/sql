USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OPERATION_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OPERATION_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OPERATION_DELETE]
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
	FROM Price.CommercialOperation
	WHERE ID = @ID
END

GO
