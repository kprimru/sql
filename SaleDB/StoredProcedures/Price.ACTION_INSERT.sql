USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[ACTION_INSERT]
	@NAME			NVARCHAR(128),
	@DELIVERY		SMALLINT,
	@SUPPORT		SMALLINT,
	@DELIVERY_FIXED	MONEY,
	@ID				UNIQUEIDENTIFIER = NULL OUTPUT
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

	INSERT INTO Price.Action(NAME, DELIVERY, SUPPORT, DELIVERY_FIXED)
		OUTPUT inserted.ID INTO @TBL
		VALUES(@NAME, @DELIVERY, @SUPPORT, @DELIVERY_FIXED)

	SELECT @ID = ID
	FROM @TBL
END

GO
