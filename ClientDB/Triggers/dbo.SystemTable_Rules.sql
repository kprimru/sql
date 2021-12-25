USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemTable_Rules]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[SystemTable_Rules]  ON [dbo].[SystemTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[SystemTable_Rules] ON [dbo].[SystemTable]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [dbo].[ClientTypeRules]([System_Id], [DistrType_Id], [ClientType_Id])
	-- ToDo заменить 3 на какое-то дефолтное значение
	SELECT S.[SystemID], D.[DistrTypeID], 3
    FROM dbo.SystemTable AS S
    CROSS JOIN dbo.DistrTypeTable AS D
    WHERE NOT EXISTS
        (
            SELECT *
            FROM dbo.ClientTypeRules AS R
            WHERE   R.[DistrType_Id] = D.[DistrTypeID]
                AND R.[System_Id] = S.[SystemID]
        );
END
GO
