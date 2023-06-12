USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Raw].[Incomes:Import?Metadata]
(
        [Id]         SmallInt       Identity(1,1)   NOT NULL,
        [Code]       VarChar(100)                   NOT NULL,
        [Caption]    VarChar(256)                   NOT NULL,
        [IsActive]   Bit                            NOT NULL,
        CONSTRAINT [PK_Raw.Incomes:Import?Metadata] PRIMARY KEY CLUSTERED ([Id])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_Raw.Incomes:Import?Metadata(Code)] ON [Raw].[Incomes:Import?Metadata] ([Code] ASC);
GO
