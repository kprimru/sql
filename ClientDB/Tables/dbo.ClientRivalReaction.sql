USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientRivalReaction]
(
        [CRR_ID]            Int             Identity(1,1)   NOT NULL,
        [CRR_ID_MASTER]     Int                                 NULL,
        [CRR_ID_RIVAL]      Int                             NOT NULL,
        [CRR_DATE]          SmallDateTime                   NOT NULL,
        [CRR_COMMENT]       VarChar(Max)                    NOT NULL,
        [CRR_COMPARE]       Bit                             NOT NULL,
        [CRR_CLAIM]         Bit                             NOT NULL,
        [CRR_REJECT]        Bit                             NOT NULL,
        [CRR_PARTNER]       Bit                             NOT NULL,
        [CRR_ACTIVE]        Bit                             NOT NULL,
        [CRR_CREATE_DATE]   DateTime                        NOT NULL,
        [CRR_CREATE_USER]   NVarChar(256)                   NOT NULL,
        [CRR_UPDATE_DATE]   DateTime                        NOT NULL,
        [CRR_UPDATE_USER]   NVarChar(256)                   NOT NULL,
        CONSTRAINT [PK_dbo.ClientRivalReaction] PRIMARY KEY NONCLUSTERED ([CRR_ID]),
        CONSTRAINT [FK_dbo.ClientRivalReaction(CRR_ID_RIVAL)_dbo.ClientRival(CR_ID)] FOREIGN KEY  ([CRR_ID_RIVAL]) REFERENCES [dbo].[ClientRival] ([CR_ID]),
        CONSTRAINT [FK_dbo.ClientRivalReaction(CRR_ID_MASTER)_dbo.ClientRivalReaction(CRR_ID)] FOREIGN KEY  ([CRR_ID_MASTER]) REFERENCES [dbo].[ClientRivalReaction] ([CRR_ID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientRivalReaction(CRR_ID_RIVAL,CRR_DATE,CRR_ID)] ON [dbo].[ClientRivalReaction] ([CRR_ID_RIVAL] ASC, [CRR_DATE] ASC, [CRR_ID] ASC);
GO
