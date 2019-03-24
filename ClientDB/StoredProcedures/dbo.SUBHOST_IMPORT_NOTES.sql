USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SUBHOST_IMPORT_NOTES]
	@DATA	VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
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
	) AS X;
	
	UPDATE SN
	SET NOTE = N.Note,
		NOTE_WTITLE = N.NoteWTitle
	FROM dbo.SystemNote SN
	INNER JOIN dbo.SystemTable S ON SN.ID_SYSTEM = S.SystemID
	INNER JOIN @Notes N ON N.SysReg = S.SystemBaseName
	WHERE IsNull(SN.NOTE, 0x) != IsNull(N.Note, 0x)
		OR IsNull(SN.NOTE_WTITLE, 0x) != IsNull(N.NoteWTitle, 0x);
		
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
END
