USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_data_from_vmi]
(
        [Ric]           SmallInt           NOT NULL,
        [System_Code]   VarChar(50)        NOT NULL,
        [Distr]         Int                NOT NULL,
        [Comp]          TinyInt            NOT NULL,
        [tech]          NVarChar(510)          NULL,
        [net]           NVarChar(510)          NULL,
        [comment]       NVarChar(510)          NULL,
);
GO
