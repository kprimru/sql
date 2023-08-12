USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Web@Confirm?Personal]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Web@Confirm?Personal]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[Web@Confirm?Personal]
    @Id			UniqueIdentifier,
    @DistrStr	NVarChar(256),
    @Psedo      NVarChar(256),
    @Email      NVarChar(256),
    @Address    NVarChar(256)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@STATUS			SmallInt,
		@MSG			NVarChar(512);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        EXEC [Seminar].[WEB_PERSONAL_CONFIRM]
			@SCHEDULE   = @Id,
			@DISTR_S    = @DistrStr,
			@PSEDO      = @Psedo,
			@EMAIL      = @Email,
			@ADDRESS    = @Address,
			@STATUS     = @STATUS OUT,
			@MSG        = @MSG OUT;

		SELECT
			[STATUS]	= @STATUS,
			[MSG]		= @MSG;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
