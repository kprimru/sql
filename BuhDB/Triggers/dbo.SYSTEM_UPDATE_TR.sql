USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[SYSTEM_UPDATE_TR]
   ON  [dbo].[SystemTable]
   AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;

    EXEC [dbo].[REFERENCES_RELOAD]
END
GO
