USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EIS@Create]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EIS@Create]
    @Act_Id			Int,
	@Invoice_Id		Int,
	@MainContent    Xml,
    @ApplyContent   Xml,
	@Document		Xml,
	@File_Id        VarChar(100),
	@SubFolder		VarChar(100) = NULL
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

		SELECT [Folder], [FileName], [Data]
		FROM [dbo].[EIS@Create(Internal)]
		(
			@Act_Id,
			@Invoice_Id,
			@MainContent,
			@ApplyContent,
			@Document,
			@File_Id,
			@SubFolder
		);

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create] TO rl_act_p;
GO
