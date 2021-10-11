USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParametersTable]
(
        [ParamName]    VarChar(20)       NOT NULL,
        [ParamValue]   VarChar(200)          NULL,
        [ParamDesc]    VarChar(200)          NULL,
);GO
GRANT SELECT ON [dbo].[ParametersTable] TO DBStatistic;
GO
