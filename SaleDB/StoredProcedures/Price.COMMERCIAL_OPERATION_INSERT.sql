USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Price].[COMMERCIAL_OPERATION_INSERT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Price].[COMMERCIAL_OPERATION_INSERT]  AS SELECT 1')
GO
ALTER PROCEDURE [Price].[COMMERCIAL_OPERATION_INSERT]
	@NAME	NVARCHAR(128),
	@ID		UNIQUEIDENTIFIER = NULL OUTPUT
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

	DECLARE @TBL TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO Price.CommercialOperation(NAME)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@NAME)

	SELECT @ID = ID
	FROM @TBL
END

GO
