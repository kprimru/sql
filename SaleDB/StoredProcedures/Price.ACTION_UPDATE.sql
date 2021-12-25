USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Price].[ACTION_UPDATE]
	@ID				UNIQUEIDENTIFIER,
	@NAME			NVARCHAR(128),
	@DELIVERY		SMALLINT,
	@SUPPORT		SMALLINT,
	@DELIVERY_FIXED	MONEY
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

	UPDATE Price.Action
	SET NAME			=	@NAME,
		DELIVERY		=	@DELIVERY,
		SUPPORT			=	@SUPPORT,
		DELIVERY_FIXED	=	@DELIVERY_FIXED,
		LAST		=	GETDATE()
	WHERE ID = @ID
END
GO
