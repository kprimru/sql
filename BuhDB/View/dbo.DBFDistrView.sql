USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[DBFDistrView]
AS
    SELECT
        [Client_Id] = CD_ID_CLIENT,
        [SystemOrder]   = SYS_ORDER,
        [Distr]         = DIS_NUM,
        [Comp]          = DIS_COMP_NUM
    FROM [PC275-SQL\DELTA].[DBF].[dbo].[ClientDistrView];
GO
