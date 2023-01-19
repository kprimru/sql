USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OPERATION_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OPERATION_UPDATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OPERATION_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	NVARCHAR(128)
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

	UPDATE Price.CommercialOperation
	SET NAME		=	@NAME,
		LAST		=	GETDATE()
	WHERE ID = @ID
END
GO
