USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Prepare]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EIS@Prepare]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EIS@Prepare]
    @Act_Id			Int,
	@Invoice_Id		Int,
	@File_Id        VarChar(100) OUTPUT,
	@IdentGUId		VarChar(100) OUTPUT
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
			@File_Id    = E.[File_Id],
			@IdentGUId  = E.[IdentGUId]
		FROM [dbo].[EIS@Prepare(Internal)](@Act_Id, @Invoice_Id) AS E;

		EXEC [dbo].[EIS@Check]
			@Act_Id		= @Act_id,
			@Invoice_Id = @Invoice_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Prepare] TO rl_act_p;
GO
