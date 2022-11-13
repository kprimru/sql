USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id			Int,
	@StageGuid		VarChar(100)	= NULL,
	@ProductGuid	VarChar(100)	= NULL,
    @Grouping		SmallInt		= 1,
	@Detail			SmallInt		= 0,
	@ActData		VarBinary(Max)	= NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @IdentGUId      VarChar(100),
        @MainContent    Xml,
        @ApplyContent   Xml,
		@MainContentS   VarChar(Max),
        @ApplyContentS  VarChar(Max),
		@Document		Xml,
        @File_Id        VarChar(100);

	DECLARE
		@Mock			Table([XmlData] Xml);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        EXEC [dbo].[EIS@Prepare]
			@Act_Id		= @Act_Id,
			@File_Id	= @File_Id OUTPUT,
			@IdentGUId	= @IdentGUId OUTPUT;

		INSERT INTO @Mock
		EXEC [dbo].[EIS@Create?Main]
			@Act_Id			= @Act_Id,
			@File_Id		= @File_Id,
			@IdentGUId		= @IdentGUId,
			@StageGuid		= @StageGuid,
			@ProductGuid	= @ProductGuid,
			@Grouping		= @Grouping,
			@Data			= @MainContent OUTPUT;

		INSERT INTO @Mock
		EXEC [dbo].[EIS@Create?Apply]
			@Act_Id			= @Act_Id,
			@File_Id		= @File_Id,
			@IdentGUId		= @IdentGUId,
			@StageGuid		= @StageGuid,
			@ProductGuid	= @ProductGuid,
			@Grouping		= @Grouping,
			@Detail			= @Detail,
			@Data			= @ApplyContent OUTPUT;

		SET @MainContentS	= Cast(@MainContent AS VarChar(Max));
		SET @ApplyContentS	= Cast(@ApplyContent AS VarChar(Max));

		INSERT INTO @Mock
		EXEC [dbo].[EIS@Create?Document]
			@Act_Id			= @Act_Id,
			@MainContent	= @MainContentS,
			@ApplyContent	= @ApplyContentS,
			@File_Id		= @File_Id,
			@Data			= @Document OUTPUT;

		EXEC [dbo].[EIS@Create]
			@Act_Id			= @Act_Id,
			@MainContent	= @MainContent,
			@ApplyContent	= @ApplyContent,
			@Document		= @Document,
			@File_Id		= @File_Id;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT?UPD] TO rl_act_p;
GO
