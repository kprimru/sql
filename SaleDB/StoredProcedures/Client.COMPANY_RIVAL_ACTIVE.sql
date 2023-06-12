﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[COMPANY_RIVAL_ACTIVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[COMPANY_RIVAL_ACTIVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[COMPANY_RIVAL_ACTIVE]
	@ID			UNIQUEIDENTIFIER
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
		UPDATE Client.CompanyRival
		SET ACTIVE = CASE ACTIVE WHEN 1 THEN 0 ELSE 1 END
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_RIVAL_ACTIVE] TO rl_rival_w;
GO
