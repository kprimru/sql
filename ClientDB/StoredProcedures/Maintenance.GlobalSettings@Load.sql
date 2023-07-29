USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Maintenance].[GlobalSettings@Load]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Maintenance].[GlobalSettings@Load]  AS SELECT 1')
GO
ALTER PROCEDURE [Maintenance].[GlobalSettings@Load]
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

		SELECT
			[Name],
			[Value],
			[DataType] = Sql_Variant_Property(G.[Value], 'BaseType')
		FROM [Maintenance].[GlobalSettings] AS G

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
