﻿USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_UPDATE_TR]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[SYSTEM_UPDATE_TR]  ON [dbo].[SystemTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
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
