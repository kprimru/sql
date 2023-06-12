USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Web@Check?Distr]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Web@Check?Distr]  AS SELECT 1')
GO
ALTER PROCEDURE [Seminar].[Web@Check?Distr]
    @Id             UniqueIdentifier,
	@DistrStr		NVarChar(64)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@MSG            NVarChar(256),
		@STATUS         SmallInt,
		@HOST           Int,
		@DISTR          Int,
		@COMP           TinyInt,
		@CLIENT         Int,
		@SubhostName    VarChar(20);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        EXEC [Seminar].[WEB_DISTR_CHECK]
			@ID             = @Id,
			@STR            = @DistrStr,
			@MSG            = @MSG OUT,
			@STATUS         = @STATUS OUT,
			@HOST           = @HOST OUT,
			@DISTR          = @DISTR OUT,
			@COMP           = @COMP OUT,
			@CLIENT         = @CLIENT OUT,
			@SubhostName    = @SubhostName OUT;

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
