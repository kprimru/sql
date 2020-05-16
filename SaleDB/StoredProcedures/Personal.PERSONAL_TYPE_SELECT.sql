USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_TYPE_SELECT]
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
		SELECT	ID,	NAME, SHORT, PSEDO
		FROM	Personal.PersonalType
		WHERE	@FILTER IS NULL
				OR (NAME LIKE @FILTER)
				OR (SHORT LIKE @FILTER)
				OR (PSEDO LIKE @FILTER)
		ORDER BY NAME

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
GRANT EXECUTE ON [Personal].[PERSONAL_TYPE_SELECT] TO rl_personal_type_r;
GO