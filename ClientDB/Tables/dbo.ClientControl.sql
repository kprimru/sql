USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientControl]
(
        [CC_ID]            Int             Identity(1,1)   NOT NULL,
        [CC_ID_CLIENT]     Int                             NOT NULL,
        [CC_BEGIN]         SmallDateTime                       NULL,
        [CC_TEXT]          VarChar(Max)                    NOT NULL,
        [CC_DATE]          DateTime                        NOT NULL,
        [CC_TYPE]          TinyInt                         NOT NULL,
        [CC_AUTHOR]        NVarChar(256)                   NOT NULL,
        [CC_READ_DATE]     DateTime                            NULL,
        [CC_READER]        NVarChar(256)                       NULL,
        [CC_REMOVE_DATE]   DateTime                            NULL,
        [CC_REMOVER]       NVarChar(256)                       NULL,
        CONSTRAINT [PK_dbo.ClientControl] PRIMARY KEY NONCLUSTERED ([CC_ID]),
        CONSTRAINT [FK_dbo.ClientControl(CC_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CC_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE CLUSTERED INDEX [IC_dbo.ClientControl(CC_ID_CLIENT,CC_REMOVE_DATE)] ON [dbo].[ClientControl] ([CC_ID_CLIENT] ASC, [CC_REMOVE_DATE] ASC);
GO
GRANT SELECT ON [dbo].[ClientControl] TO Чемерис;
GO
