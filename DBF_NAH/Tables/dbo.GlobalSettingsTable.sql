USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GlobalSettingsTable]
(
        [GS_ID]       SmallInt       Identity(1,1)   NOT NULL,
        [GS_NAME]     VarChar(50)                    NOT NULL,
        [GS_VALUE]    VarChar(500)                   NOT NULL,
        [GS_ACTIVE]   Bit                            NOT NULL,
        CONSTRAINT [PK_dbo.GlobalSettingsTable] PRIMARY KEY CLUSTERED ([GS_ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_dbo.GlobalSettingsTable()] ON [dbo].[GlobalSettingsTable] ([GS_NAME] ASC);
GO
