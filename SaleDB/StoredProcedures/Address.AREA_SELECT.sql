USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Address].[AREA_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Address].[AREA_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Address].[AREA_SELECT]
	@FILTER	NVARCHAR(256),
	@RC		INT	= NULL OUTPUT
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
		SELECT	a.ID, a.NAME, b.NAME AS CT_NAME
		FROM
			Address.Area a
			INNER JOIN Address.City b ON a.ID_CITY = b.ID
		WHERE	@FILTER IS NULL
				OR (a.NAME LIKE @FILTER)
		ORDER BY a.NAME, b.NAME

		SET @RC = @@ROWCOUNT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Address].[AREA_SELECT] TO rl_area_r;
GO
