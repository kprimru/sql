USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ActDistrSync]', 'TR') IS NULL EXEC('CREATE TRIGGER [dbo].[ActDistrSync]  ON [dbo].[ActDistrTable] AFTER INSERT,UPDATE,DELETE  AS SELECT 1')
GO
ALTER TRIGGER [dbo].[ActDistrSync]
   ON  [dbo].[ActDistrTable]
   AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Distrs Table
    (
        SYS_REG_NAME    VarChar(20),
        DIS_NUM         Int,
        DIS_COMP_NUM    TinyInt
        Primary Key Clustered (DIS_NUM, SYS_REG_NAME, DIS_COMP_NUM)
    );

    INSERT INTO @Distrs
    SELECT DISTINCT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
    FROM
    (
        SELECT AD_ID_DISTR
        FROM inserted I

        UNION

        SELECT AD_ID_DISTR
        FROM deleted D
    ) T
    INNER JOIN dbo.DistrTable D ON D.DIS_ID = T.AD_ID_DISTR
    INNER JOIN dbo.SystemTable S ON S.SYS_ID = D.DIS_ID_SYSTEM;

    UPDATE S
    SET UPD_DATE = GetDate()
    FROM Sync.DistrFinancing    S
    INNER JOIN @Distrs          D ON    D.SYS_REG_NAME  = S.SYS_REG_NAME
                                    AND	D.DIS_NUM       = S.DIS_NUM
                                    AND D.DIS_COMP_NUM  = S.DIS_COMP_NUM;

    INSERT INTO Sync.DistrFinancing(SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM)
    SELECT SYS_REG_NAME, DIS_NUM, DIS_COMP_NUM
    FROM @Distrs D
    WHERE NOT EXISTS
        (
            SELECT *
            FROM Sync.DistrFinancing S
            WHERE	D.SYS_REG_NAME  = S.SYS_REG_NAME
                AND D.DIS_NUM       = S.DIS_NUM
                AND D.DIS_COMP_NUM  = S.DIS_COMP_NUM
        );
END
GO
