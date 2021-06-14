USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    EXEC [Claim].[Claims@Report]
        @DateFrom = '20200101',
        @DateTo   = '20201231';
*/
ALTER PROCEDURE [Claim].[Claims@Report]
    @Types          NVarChar(MAX)       = NULL,
    @DateFrom       SmallDateTime       = NULL,
    @DateTo         SmallDateTime       = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @TypesIDs Table
    (
        [Id]    TinyInt NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE @IDs Table
    (
        [Id]    Int NOT NULL PRIMARY KEY CLUSTERED
    );

    DECLARE @Result Table
    (
        [Id]            Int             NOT NULL    Identity(1,1),
        [Parent_Id]     Int                 NULL,
        [Name]          VarChar(256)    NOT NULL,
        [Value]         VarChar(256)        NULL,
        PRIMARY KEY CLUSTERED([Id])
    );

    DECLARE @Parent_Id Int;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY
        SET @DateTo = DateAdd(Day, 1, @DateTo);

        IF @Types IS NOT NULL
            INSERT INTO @TypesIDs
            SELECT ID
            FROM [Common].[TableIDFromXML](@Types);
        ELSE
            INSERT INTO @TypesIDs
            SELECT [Id]
            FROM [Claim].[Claims->Types];

        INSERT INTO @IDs
        SELECT C.[Id]
        FROM [Claim].[Claims] AS C
        INNER JOIN @TypesIDs AS T ON C.[Type_Id] = T.[Id]
        WHERE (C.[CreateDateTime] >= @DateFrom OR @DateFrom IS NULL)
            AND (C.[CreateDateTime] < @DateTo OR @DateTo IS NULL);

        INSERT INTO @Result([Name], [Value])
        SELECT 'Количество заявок', Count(*)
        FROM @IDs;

        SET @Parent_Id = Scope_Identity();

        INSERT INTO @Result([Parent_Id], [Name], [Value])
        SELECT @Parent_Id, T.[Name], [Count] = Count(*)
        FROM @IDs AS I
        INNER JOIN [Claim].[Claims] AS C ON I.[Id] = C.[Id]
        INNER JOIN [Claim].[Claims->Types] AS T ON C.[Type_Id] = T.[Id]
        GROUP BY T.[Name]
        ORDER BY [Count] DESC;

        INSERT INTO @Result([Name], [Value])
        SELECT 'Статусы заявок', NULL;

        SET @Parent_Id = Scope_Identity();

        INSERT INTO @Result([Parent_Id], [Name], [Value])
        SELECT @Parent_Id, S.[Name], [Count] = Count(*)
        FROM @IDs AS I
        INNER JOIN [Claim].[Claims] AS C ON I.[Id] = C.[Id]
        INNER JOIN [Claim].[Claims->Statuses] AS S ON C.[Status_Id] = S.[Id]
        GROUP BY S.[Name]
        ORDER BY [Count] DESC

        INSERT INTO @Result([Name], [Value])
        SELECT 'Привязаны к карточкам', NULL;

        SET @Parent_Id = Scope_Identity();

        INSERT INTO @Result([Parent_Id], [Name], [Value])
        SELECT @Parent_Id, R.[Result], [Count] = Count(*)
        FROM @IDs AS I
        INNER JOIN [Claim].[Claims] AS C ON I.[Id] = C.[Id]
        CROSS APPLY
        (
            SELECT TOP (1) [SENDER_NOTE], [BDATE]
            FROM [Client].[Company] AS CMP
            WHERE CMP.[ID] = C.Company_Id OR CMP.[ID_MASTER] = C.[Company_Id]
            ORDER BY CMP.[BDATE]
        ) AS CMP
        CROSS APPLY
        (
            SELECT
                [Result] =
                            CASE
                                WHEN CMP.[SENDER_NOTE] = Cast(C.[Number] AS VarChar(100)) THEN 'Новая карточка'
                                ELSE 'Существующая карточка'
                            END
        ) AS R
        WHERE C.[Company_Id] IS NOT NULL
        GROUP BY R.[Result];

        SELECT *
        FROM @Result;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Claim].[Claims@Report] TO rl_claim_report;
GO