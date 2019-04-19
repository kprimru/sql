USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WEIGHT_TREE_SELECT]
AS
DECLARE @Params Table
(
    [Sys]       VarChar(50)     NOT NULL,
    [SysType]   VarChar(50)     NOT NULL,
    [NetType]   VarChar(50)     NOT NULL,
    [Date]      DateTime        NOT NULL,
    [Weight]    Decimal(8,4)    NOT NULL,
    Primary Key Clustered([Sys], [SysType], [NetType], [Date])
);

INSERT INTO @Params
SELECT [SysName], [SysTypeName], [NetTypeName], GetDate(), [SysCoef] * [SysTypeCoef] * [NetTypeCoef]
FROM
(
    SELECT 'Проф', 1
	UNION ALL
    SELECT 'БОВП', 1.1
	UNION ALL
    SELECT 'ЮВП', 1.1
	UNION ALL
    SELECT 'БВП', 1.1
	UNION ALL
    SELECT 'КБ:Проф', 0.65
	UNION ALL
    SELECT 'КБс', 0.65
	UNION ALL
    SELECT 'МБП', 0.65
	UNION ALL
    SELECT 'БО', 0.65
) AS Systems([SysName], [SysCoef])
CROSS JOIN
(
    SELECT 'КОМ', 1
	UNION ALL
    SELECT 'VIP', 1
	UNION ALL
    SELECT 'С.Л', 1
	UNION ALL
    SELECT 'С.В', 1
	UNION ALL
    SELECT 'ДСП', 0
	UNION ALL
    SELECT 'С.С', 0
	UNION ALL
    SELECT 'LSV', 0
	UNION ALL
    SELECT 'СПЕЦ', 0.1
	UNION ALL
    SELECT 'DD3', 1.2
	UNION ALL
    SELECT 'DZ3', 1.2
) AS SystemTypes([SysTypeName], [SysTypeCoef])
CROSS JOIN
(
    SELECT 'лок', 1
	UNION ALL
    SELECT 'флэш', 1
	UNION ALL
    SELECT 'ОВП', 1
	UNION ALL
    SELECT 'ОВК', 1
	UNION ALL
    SELECT 'ОВПИ', 1
	UNION ALL
    SELECT 'с/о', 1.25
	UNION ALL
    SELECT 'м/с', 2
	UNION ALL
    SELECT 'сеть 50', 2.1
	UNION ALL
    SELECT 'сеть 100', 2.1
	UNION ALL
    SELECT 'сеть 150', 2.1
	UNION ALL
    SELECT 'сеть 200', 2.1
	UNION ALL
    SELECT 'сеть 255', 2.1
) AS NetTypes([NetTypeName], [NetTypeCoef]);

DECLARE @Data Table
(
    [Systems]   VarChar(Max),
    [Types]     VarChar(Max),
    [Nets]      VarChar(Max),
    [Weight]    Decimal(8,4)
);

INSERT INTO @Data
SELECT DISTINCT
    [SystemGroups]      = SWT.[SystemGroups],
    [SystemTypesGroups] = SWT.[SystemTypesGroups],
    [NetTypeGroups]     = 
                (
                    REVERSE(STUFF(REVERSE(
                        (
                            SELECT [NetType] + ','
                            FROM
                            (
                                SELECT DISTINCT S.[NetType]
                                FROM @Params S
                                WHERE S.[Weight] = SWT.[Weight]
                                    AND SWT.[SystemGroups] LIKE '%'+S.[Sys]+'%'
                                    AND SWT.[SystemTypesGroups] LIKE '%'+S.[SysType]+'%'
                            ) AS X
                            FOR XML PATH('')
                        )), 1, 1, ''))
                ),
    [Weight]            = SWT.[Weight]
FROM
(
    SELECT DISTINCT
        [SystemGroups] = SW.[SystemGroups],
        [SystemTypesGroups] = 
                (
                    REVERSE(STUFF(REVERSE(
                        (
                            SELECT [SysType] + ','
                            FROM
                            (
                                SELECT DISTINCT S.[SysType]
                                FROM @Params S
                                WHERE S.[Weight] = SW.[Weight]
                                    AND SW.[SystemGroups] LIKE '%'+S.[Sys]+'%'
                            ) AS X
                            FOR XML PATH('')
                        )), 1, 1, ''))
                ),
        [Weight]       = SW.[Weight]
    FROM
    (
        SELECT DISTINCT
            [SystemGroups] =
                (
                    REVERSE(STUFF(REVERSE(
                        (
                            SELECT [Sys] + ','
                            FROM
                            (
                                SELECT DISTINCT S.[Sys]
                                FROM @Params S
                                WHERE S.[Weight] = P.[Weight]
                            ) AS X
                            FOR XML PATH('')
                        )), 1, 1, ''))
                ),
            [Weight] = P.[Weight]
        FROM @Params P
    ) SW
) SWT
-------------------------------------------------------------------------------------------
DECLARE @Result Table
(
    [Id]        Int             Identity(1,1)   NOT NULL,
    [Parent_Id] Int                                 NULL,
    [Data]      NVarChar(256)                    NOT NULL,
    [Weight]    Decimal(8,4)                        NULL,
    PRIMARY KEY CLUSTERED ([Id])
);

-- заполняем системы
INSERT INTO @Result([Data])
SELECT DISTINCT
    [Systems]
FROM @Data;

-- заполнем типы систем
INSERT INTO @Result([Parent_Id], [Data])
SELECT R.[Id], [Types]
FROM
(
    SELECT DISTINCT [Systems], [Types]
    FROM @Data
) D
INNER JOIN @Result R ON R.[Data] = D.[Systems] AND R.[Parent_Id] IS NULL;

-- заполняем сетевитость и вес для нее
INSERT INTO @Result([Parent_Id], [Data], [Weight])
SELECT
    (
        SELECT TOP (1) R.[Id]
        FROM @Result R
        WHERE R.[Data] = D.[Types]
            AND R.[Parent_Id] = 
                (
                    SELECT TOP (1) [Id]
                    FROM @Result S
                    WHERE S.[Data] = D.[Systems]
                )
    ), D.[Nets], D.[Weight]
FROM @Data D

SELECT *
FROM @Result;