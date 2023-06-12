﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Sale].[SALE_TYPE_GET]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Sale].[SALE_TYPE_GET]  AS SELECT 1')
GO
ALTER PROCEDURE [Sale].[SALE_TYPE_GET]
	@ID		UNIQUEIDENTIFIER
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
		SELECT	ID, NAME
		FROM	Sale.SaleType
		WHERE	ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Sale].[SALE_TYPE_GET] TO rl_sale_type_r;
GO
