USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[DAY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Common].[DAY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Common].[DAY_SELECT]
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

	SELECT ID, NAME, SHORT, NUM
	FROM Common.Day
	ORDER BY NUM
END
GO
GRANT EXECUTE ON [Common].[DAY_SELECT] TO public;
GO
