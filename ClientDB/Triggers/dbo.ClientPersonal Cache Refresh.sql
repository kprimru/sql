USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[ClientPersonal Cache Refresh]
   ON  [dbo].[ClientPersonal]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Surname	VarChar(250),
		@Name		VarChar(250),
		@Patron		VarChar(250),
		@Position	VarChar(250),
		
		@RowCount	Int;
		
	SET @RowCount = (SELECT COUNT(*) FROM inserted);
	
	IF @RowCount = 1 BEGIN
		-- ���� ������ ���� ������ - ������� ����������� �� ��� ���
		SELECT TOP (1)
			@Surname	= CP_SURNAME,
			@Name		= CP_NAME,
			@Patron		= CP_PATRON,
			@Position	= CP_POS
		FROM inserted;
		
		EXEC [Cache].[NAME_CACHE_REFRESH]		@Name = @Name;
		EXEC [Cache].[SURNAME_CACHE_REFRESH]	@Surname = @Surname;
		EXEC [Cache].[PATRON_CACHE_REFRESH]		@Patron = @Patron;
		EXEC [Cache].[POSITION_CACHE_REFRESH]	@Position = @Position;
	END ELSE BEGIN
		-- ���� ������ 1 ������ ����������� - �� ������������� ���� ���
		EXEC [Cache].[NAME_CACHE_REFRESH]
		EXEC [Cache].[SURNAME_CACHE_REFRESH]
		EXEC [Cache].[PATRON_CACHE_REFRESH]
		EXEC [Cache].[POSITION_CACHE_REFRESH]
	END;
END
