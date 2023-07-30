USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClaimTable]
(
        [CLM_ID]               Int            Identity(1,1)   NOT NULL,
        [CLM_ID_CLAIM]         Int                            NOT NULL,
        [CLM_ID_CLIENT]        Int                            NOT NULL,
        [CLM_DATE]             DateTime                       NOT NULL,
        [CLM_AUTHOR]           VarChar(150)                   NOT NULL,
        [CLM_STATUS]           VarChar(50)                        NULL,
        [CLM_TYPE]             VarChar(150)                       NULL,
        [CLM_ACTION_BEFORE]    VarChar(Max)                       NULL,
        [CLM_PROBLEM]          VarChar(Max)                       NULL,
        [CLM_AFTER]            VarChar(Max)                       NULL,
        [CLM_EX_DATE]          DateTime                           NULL,
        [CLM_REAL_TYPE]        VarChar(150)                       NULL,
        [CLM_EXECUTOR]         VarChar(150)                       NULL,
        [CLM_COMMENT]          VarChar(Max)                       NULL,
        [CLM_EXECUTE_ACTION]   VarChar(Max)                       NULL,
        CONSTRAINT [PK_dbo.ClaimTable] PRIMARY KEY CLUSTERED ([CLM_ID]),
        CONSTRAINT [FK_dbo.ClaimTable(CLM_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CLM_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE NONCLUSTERED INDEX [IX_dbo.ClaimTable(CLM_ID_CLIENT)+(CLM_ID,CLM_ID_CLAIM,CLM_DATE,CLM_AUTHOR,CLM_STATUS,CLM_TYPE,CLM_ACTION_BEFORE,CLM_PROBLEM,CLM_] ON [dbo].[ClaimTable] ([CLM_ID_CLIENT] ASC) INCLUDE ([CLM_ID], [CLM_ID_CLAIM], [CLM_DATE], [CLM_AUTHOR], [CLM_STATUS], [CLM_TYPE], [CLM_ACTION_BEFORE], [CLM_PROBLEM], [CLM_AFTER], [CLM_EX_DATE], [CLM_REAL_TYPE], [CLM_EXECUTOR], [CLM_COMMENT], [CLM_EXECUTE_ACTION]);
GO
GRANT DELETE ON [dbo].[ClaimTable] TO claim_view;
GRANT INSERT ON [dbo].[ClaimTable] TO claim_view;
GRANT SELECT ON [dbo].[ClaimTable] TO claim_view;
GRANT UPDATE ON [dbo].[ClaimTable] TO claim_view;
GO
