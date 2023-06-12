﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[NetTypes@Get?Online]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[NetTypes@Get?Online] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [dbo].[NetTypes@Get?Online]()
RETURNS TABLE
AS
RETURN
(
    SELECT SNC.[SNC_ID_SN]
    FROM [dbo].[SystemNetCountTable] AS SNC
    WHERE SNC.[SNC_TECH] > 3
)
GO
