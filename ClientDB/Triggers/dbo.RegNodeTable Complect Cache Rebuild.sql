USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[RegNodeTable Complect Cache Rebuild]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[RegNodeTable Complect Cache Rebuild]  ON [dbo].[RegNodeTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[RegNodeTable Complect Cache Rebuild]
   ON  [dbo].[RegNodeTable]
   AFTER INSERT,DELETE,UPDATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Id			Int,
		@Complect	VarChar(100);

    DECLARE @Complects Table
    (
		[Id]		Int				Identity(1,1),
		[Complect]	VarChar(100),
		Primary Key Clustered([Id])
    );

    INSERT INTO @Complects
    SELECT Complect
    FROM inserted
    WHERE Complect IS NOT NULL

    UNION --DISTINCT

    SELECT Complect
    FROM deleted
    WHERE Complect IS NOT NULL;

	SET @Id = 0;

    WHILE (1 = 1) BEGIN
		SELECT TOP (1)
			@Id = [Id],
			@Complect = [Complect]
		FROM @Complects
		WHERE [Id] > @Id
		ORDER BY
			[Id];

		IF @@RowCount < 1
			BREAK;

		EXEC dbo.COMPLECT_INFO_BANK_CACHE_RESET @Complect = @Complect;
    END
END
GO
