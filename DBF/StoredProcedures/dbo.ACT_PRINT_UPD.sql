USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_PRINT?UPD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_PRINT?UPD]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_PRINT?UPD]
    @Act_Id			Int				= NULL,
	@Invoice_Id		Int				= NULL,
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

		EXEC [dbo].[EIS@Check]
			@Act_Id = @Act_id,
			@Invoice_Id = @Invoice_Id;

		SELECT
			@File_Id    = E.[File_Id],
			@IdentGUId  = E.[IdentGUId]
		FROM [dbo].[EIS@Prepare(Internal)](@Act_Id) AS E;

		SELECT @MainContent = M.[Data]
		FROM [dbo].[EIS@Create?Main(Internal)]
			(
				@Act_Id,
				@Invoice_Id,
				@File_Id,
				@IdentGUId,
				@StageGuid,
				@ProductGuid,
				@Grouping
			) AS M;

		SELECT @ApplyContent = A.[Data]
		FROM [dbo].[EIS@Create?Apply(Internal)]
		(
			    @Act_Id,
				@Invoice_Id,
				@File_Id,
				@IdentGUId,
				@StageGuid,
				@ProductGuid,
				@Grouping,
				@Detail
		) AS A;

		SET @MainContentS	= Cast(@MainContent AS VarChar(Max));
		SET @ApplyContentS	= Cast(@ApplyContent AS VarChar(Max));

		SELECT @Document = D.[Data]
		FROM [dbo].[EIS@Create?Document(Internal)]
		(
			@Act_Id,
			@Invoice_Id,
			@File_Id,
			@MainContentS,
			@ApplyContentS
		) AS D;

		EXEC [dbo].[EIS@Create]
			@Act_Id			= @Act_Id,
			@Invoice_Id		= @Invoice_Id,
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
