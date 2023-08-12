USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[OnlineActivity@Parse?Login]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[OnlineActivity@Parse?Login] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE OR ALTER FUNCTION [dbo].[OnlineActivity@Parse?Login]
(
    @Login  VarChar(256)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        [Host_Id]   = H.[HostID],
        [Distr]     = D.[Distr],
        [Comp]      = D.[Comp]
    FROM [dbo].[Hosts] AS H
    OUTER APPLY
    (
        SELECT [DistrStr] =
            CASE
                WHEN @Login = 'null' THEN null
                ELSE
                    CASE CharIndex('#', @Login)
                        WHEN 0 THEN @Login
                        ELSE Left(@Login, CharIndex('#', @Login) - 1)
                    END
            END
    ) AS DS
    OUTER APPLY
    (
        SELECT
            [Distr] =
                CASE CharIndex('_', DS.[DistrStr])
                    WHEN 0 THEN Cast(DS.[DistrStr] AS Int)
                    ELSE Cast(Left(DS.[DistrStr], CharIndex('_', DS.[DistrStr]) - 1) AS Int)
                END,
            [Comp] =
                CASE CharIndex('_', DS.[DistrStr])
                    WHEN 0 THEN 1
                    ELSE Cast(Right(DS.[DistrStr], Len(DS.[DistrStr]) - CharIndex('_', DS.[DistrStr])) AS Int)
                END
    ) AS D
    WHERE [HostReg] = 'LAW'
)
GO
