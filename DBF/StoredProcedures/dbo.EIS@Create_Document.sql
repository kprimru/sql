USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Create?Document]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EIS@Create?Document]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EIS@Create?Document]
    @Act_Id			Int,
	@File_Id        VarChar(100),
	@MainContent    VarChar(Max),
    @ApplyContent   VarChar(Max),
	@Data			Xml				= NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@DocumentXml	Xml,
		@MainBase64     VarChar(Max),
        @ApplyBase64    VarChar(Max);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

		SELECT @Data = D.[Data]
		FROM [dbo].[EIS@Create?Document(Internal)]
		(
			@Act_Id,
			@File_Id,
			@MainContent,
			@ApplyContent
		) AS D;

		SELECT [Data] = Cast(@DocumentXml AS VarChar(Max));

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Create?Document] TO rl_act_p;
GO
