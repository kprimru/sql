USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReferenceTable]
(
        [REF_ID]           SmallInt      Identity(1,1)   NOT NULL,
        [REF_SCHEMA]       VarChar(50)                   NOT NULL,
        [REF_NAME]         VarChar(50)                   NOT NULL,
        [REF_TITLE]        VarChar(50)                   NOT NULL,
        [REF_FIELD_ID]     VarChar(50)                   NOT NULL,
        [REF_FIELD_NAME]   VarChar(50)                   NOT NULL,
        [REF_READ_ONLY]    Bit                           NOT NULL,
        [REF_EMPTY_ID]     Int                               NULL,
        CONSTRAINT [PK_dbo.ReferenceTable] PRIMARY KEY CLUSTERED ([REF_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.ReferenceTable()] ON [dbo].[ReferenceTable] ([REF_NAME] ASC);
GO
