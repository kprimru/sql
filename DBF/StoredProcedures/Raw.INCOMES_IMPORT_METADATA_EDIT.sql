﻿USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Raw].[INCOMES_IMPORT_METADATA_EDIT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_EDIT]  AS SELECT 1')
GO
ALTER PROCEDURE [Raw].[INCOMES_IMPORT_METADATA_EDIT]
    @Id             SmallInt,
    @Code           VarChar(100),
    @Caption        VarChar(256),
    @IsActive       Bit = 1
AS
BEGIN
    SET NOCOUNT ON

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        UPDATE Raw.[Incomes:Import?Metadata] SET
            Code        = @Code,
            Caption     = @Caption,
            IsActive    = @IsActive
        WHERE Id = @Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Raw].[INCOMES_IMPORT_METADATA_EDIT] TO rl_incomes_import_metadata_w;
GO
