USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemsNotes@Select]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SystemsNotes@Select]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SystemsNotes@Select]
    @Filter  VarChar(256)    =    NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	DECLARE
		@Systems	Table(Id Int Primary Key Clustered);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO @Systems
		SELECT [SystemID]
		FROM [dbo].[SystemTable]
		WHERE @Filter IS NULL
			OR [SystemBaseName] LIKE @Filter
			OR [SystemShortName] LIKE @Filter;

        SELECT
            [Id]                = Cast([SystemId] AS VarChar(10)),
            [Parent_Id]         = NULL,
            [System_Id]         = S.[SystemID],
            [DistrType_Id]      = NULL,
            [Name]              = S.[SystemShortName],
            [NoteStr]           = dbo.FileByteSizeToStr(Len(N.[NOTE])),
            [NoteWTitleStr]     = dbo.FileByteSizeToStr(Len(N.[NOTE_WTITLE])),
            [Ord]               = S.[SystemOrder]
        FROM [dbo].[SystemTable]        AS S
        LEFT JOIN [dbo].[SystemNote]    AS N ON N.[ID_SYSTEM] = S.[SystemID]
        WHERE S.[SystemID] IN (SELECT F.[Id] FROM @Systems AS F)

        UNION ALL

        SELECT
            [Id]                = Cast([System_Id] AS VarChar(10)) + ':' + Cast([DistrType_Id] AS VarChar(10)),
            [Parent_Id]         = Cast([System_Id] AS VarChar(10)),
            [System_Id]         = SD.[System_Id],
            [DistrType_Id]      = SD.[DistrType_Id],
            [Name]              = D.[DistrTypeName],
            [NoteStr]           = dbo.FileByteSizeToStr(Len(SD.[Note])),
            [NoteWTitleStr]     = dbo.FileByteSizeToStr(Len(SD.[NoteWTitle])),
            [Ord]               = D.[DistrTypeOrder]
        FROM [dbo].[SystemNote:DistrType]   AS SD
        INNER JOIN [dbo].[DistrTypeTable]   AS D ON SD.[DistrType_Id] = D.[DistrTypeID]
        WHERE SD.[System_ID] IN (SELECT F.[Id] FROM @Systems AS F)
        ORDER BY [Ord];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SystemsNotes@Select] TO rl_system_note_r;
GO
