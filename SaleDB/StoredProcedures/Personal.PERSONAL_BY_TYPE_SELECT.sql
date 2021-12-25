USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Personal].[PERSONAL_BY_TYPE_SELECT]
	@TYPE	NVARCHAR(64)
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
		SELECT ID, SHORT
		FROM Personal.OfficePersonal a
		WHERE END_DATE IS NULL
			AND EXISTS
				(
					SELECT *
					FROM
						Personal.OfficePersonalType b
						INNER JOIN Personal.PersonalType c ON b.ID_TYPE = c.ID
					WHERE b.ID_PERSONAL = a.ID AND b.EDATE IS NULL
						AND c.PSEDO = @TYPE
				)
		ORDER BY SHORT

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Personal].[PERSONAL_BY_TYPE_SELECT] TO rl_personal_r;
GO
