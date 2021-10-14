USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientSatisfaction]
(
        [CS_ID]        UniqueIdentifier      NOT NULL,
        [CS_ID_CALL]   UniqueIdentifier      NOT NULL,
        [CS_ID_TYPE]   UniqueIdentifier      NOT NULL,
        [CS_NOTE]      VarChar(Max)          NOT NULL,
        [CS_TYPE]      TinyInt               NOT NULL,
        CONSTRAINT [PK_dbo.ClientSatisfaction] PRIMARY KEY NONCLUSTERED ([CS_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfaction(CS_ID_CALL)_dbo.ClientCall(CC_ID)] FOREIGN KEY  ([CS_ID_CALL]) REFERENCES [dbo].[ClientCall] ([CC_ID]),
        CONSTRAINT [FK_dbo.ClientSatisfaction(CS_ID_TYPE)_dbo.SatisfactionType(STT_ID)] FOREIGN KEY  ([CS_ID_TYPE]) REFERENCES [dbo].[SatisfactionType] ([STT_ID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientSatisfaction(CS_ID_CALL)] ON [dbo].[ClientSatisfaction] ([CS_ID_CALL] ASC);
GO
