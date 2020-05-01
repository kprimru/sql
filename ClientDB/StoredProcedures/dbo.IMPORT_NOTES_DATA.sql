USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IMPORT_NOTES_DATA]
	@DATA		NVARCHAR(MAX),
	@OUT_DATA	NVARCHAR(512) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @XML XML

		DECLARE @ADD	INT
		DECLARE @UPDATE	INT

		SET @ADD = 0

		SET @XML = CAST(@DATA AS XML)

		DECLARE @Notes Table
		(
			SysReg		VarChar(100),
			Note		VarBinary(Max),
			NoteWTitle	VarBinary(Max),
			Primary Key Clustered (SysReg)
		);

		INSERT INTO @Notes
		SELECT Reg, Note, Note_WTitle
		FROM
		(
			SELECT
				[Reg] = c.value('@Reg[1]', 'VarCHar(20)'),
				[Note] = c.value('(./Note)[1]', 'VarBinary(Max)'),
				[Note_WTitle] = c.value('(./Note_WTitle)[1]', 'VarBinary(Max)')
			FROM @Xml.nodes('/System') AS R(c)
		) AS X
		WHERE X.[Note] IS NOT NULL;

		UPDATE SN
		SET NOTE = N.Note,
			NOTE_WTITLE = N.NoteWTitle
		FROM dbo.SystemNote SN
		INNER JOIN dbo.SystemTable S ON SN.ID_SYSTEM = S.SystemID
		INNER JOIN @Notes N ON N.SysReg = S.SystemBaseName
		WHERE IsNull(SN.NOTE, 0x) != IsNull(N.Note, 0x)
			OR IsNull(SN.NOTE_WTITLE, 0x) != IsNull(N.NoteWTitle, 0x);

		SET @UPDATE = @@ROWCOUNT;

		INSERT INTO dbo.SystemNote(ID_SYSTEM, NOTE, NOTE_WTITLE)
		SELECT SystemID, N.Note, N.NoteWTitle
		FROM @Notes N
		INNER JOIN dbo.SystemTable S ON N.SysReg = S.SystemBaseName
		WHERE NOT EXISTS
			(
				SELECT *
				FROM dbo.SystemNote SN
				WHERE SN.ID_SYSTEM = S.SystemID
			);

		SET @ADD = @@ROWCOUNT

		SET @OUT_DATA = 'Добавлено ' + CONVERT(NVARCHAR(32), @ADD) + ' записей. Обновлено ' + CONVERT(NVARCHAR(32), @UPDATE) + ' записей.'

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[IMPORT_NOTES_DATA] TO rl_import_data;
GO