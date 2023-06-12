USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FieldTable]
(
        [FL_ID]          Int           Identity(1,1)   NOT NULL,
        [FL_NAME]        VarChar(50)                   NOT NULL,
        [FL_WIDTH]       Int                           NOT NULL,
        [FL_CAPTION]     VarChar(50)                       NULL,
        [FL_MAX_WIDTH]   Int                               NULL,
        [FL_MIN_WIDTH]   Int                               NULL,
        CONSTRAINT [PK_dbo.FieldTable] PRIMARY KEY CLUSTERED ([FL_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.FieldTable(FL_NAME)] ON [dbo].[FieldTable] ([FL_NAME] ASC);
GO
