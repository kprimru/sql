USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientCall]
(
        [CC_ID]          UniqueIdentifier      NOT NULL,
        [CC_ID_CLIENT]   Int                   NOT NULL,
        [CC_DATE]        SmallDateTime         NOT NULL,
        [CC_PERSONAL]    VarChar(250)          NOT NULL,
        [CC_SERVICE]     VarChar(150)          NOT NULL,
        [CC_NOTE]        VarChar(Max)          NOT NULL,
        [CC_USER]        NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientCall] PRIMARY KEY NONCLUSTERED ([CC_ID]),
        CONSTRAINT [FK_dbo.ClientCall(CC_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CC_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientCall(CC_ID_CLIENT,CC_ID,CC_DATE)] ON [dbo].[ClientCall] ([CC_ID_CLIENT] ASC, [CC_ID] ASC, [CC_DATE] ASC);
CREATE NONCLUSTERED INDEX [IX_dbo.ClientCall(CC_DATE)] ON [dbo].[ClientCall] ([CC_DATE] ASC);
GO
