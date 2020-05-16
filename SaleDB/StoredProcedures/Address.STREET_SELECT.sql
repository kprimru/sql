USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Address].[STREET_SELECT]
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
		SELECT	a.ID, a.NAME, a.PREFIX, SUFFIX, b.NAME AS CT_NAME, a.NAME + ', ' + b.NAME AS FULL_STR
		FROM
			Address.Street a
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
GRANT EXECUTE ON [Address].[STREET_SELECT] TO rl_street_r;
GO