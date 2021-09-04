USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Subhost]
(
        [SH_ID]                      UniqueIdentifier      NOT NULL,
        [SH_NAME]                    VarChar(100)          NOT NULL,
        [SH_REG]                     VarChar(20)           NOT NULL,
        [SH_REG_ADD]                 VarChar(20)               NULL,
        [SH_EMAIL]                   VarChar(50)               NULL,
        [SH_ID_CLIENT]               Int                       NULL,
        [SH_SEMINAR_DEFAULT_COUNT]   SmallInt                  NULL,
        CONSTRAINT [PK_dbo.Subhost] PRIMARY KEY CLUSTERED ([SH_ID]),
        CONSTRAINT [FK_dbo.Subhost(SH_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([SH_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);GO
