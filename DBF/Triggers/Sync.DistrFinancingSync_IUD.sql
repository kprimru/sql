USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Sync].[DistrFinancingSync_IUD]', 'TR') IS NULL EXEC('CREATE TRIGGER [Sync].[DistrFinancingSync_IUD]  ON [Sync].[DistrFinancing] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [Sync].[DistrFinancingSync_IUD]
   ON  [Sync].[DistrFinancing]
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	SET NOCOUNT ON;

    INSERT INTO Sync.DistrFinancingLog
	SELECT *, 'I'
	FROM inserted
	UNION ALL
	SELECT *, 'D'
	FROM deleted
END
GO
