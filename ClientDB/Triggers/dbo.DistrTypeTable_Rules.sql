USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[DistrTypeTable_Rules]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[DistrTypeTable_Rules]  ON [dbo].[DistrTypeTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[DistrTypeTable_Rules] ON [dbo].[DistrTypeTable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefaultCategory_Id SmallInt;

	SELECT TOP (1) @DefaultCategory_Id = ClientTypeID
	FROM [dbo].[ClientTypeTable]
	ORDER BY [SortIndex] DESC;

	INSERT INTO [dbo].[ClientTypeRules]([System_Id], [DistrType_Id], [ClientType_Id])
	SELECT S.[SystemID], D.[DistrTypeID], @DefaultCategory_Id
    FROM [dbo].[SystemTable] AS S
    CROSS JOIN [dbo].[DistrTypeTable] AS D
    WHERE NOT EXISTS
        (
            SELECT *
            FROM [dbo].[ClientTypeRules] AS R
            WHERE   R.[DistrType_Id] = D.[DistrTypeID]
                AND R.[System_Id] = S.[SystemID]
        );
END
GO
