USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientOri]
(
        [CO_ID]             UniqueIdentifier      NOT NULL,
        [CO_ID_CLIENT]      Int                   NOT NULL,
        [CO_NAME]           VarChar(250)          NOT NULL,
        [CO_VISIT]          VarChar(100)              NULL,
        [CO_INFORMATION]    VarChar(Max)              NULL,
        [CO_RES_NAME]       VarChar(250)              NULL,
        [CO_RES_PHONE]      VarChar(100)              NULL,
        [CO_RES_POSITION]   VarChar(100)              NULL,
        [CO_RES_PLACE]      VarChar(100)              NULL,
        [CO_STUDY]          VarChar(100)              NULL,
        [CO_CLAIM]          VarChar(Max)              NULL,
        [CO_CURR_STATUS]    VarChar(100)              NULL,
        [CO_PLAN_ACTION]    VarChar(Max)              NULL,
        [CO_RESULT]         VarChar(Max)              NULL,
        [CO_RIVAL]          VarChar(Max)              NULL,
        [CO_NOTE]           VarChar(Max)              NULL,
        [CO_STATUS]         TinyInt               NOT NULL,
        [CO_DATE]           DateTime              NOT NULL,
        [CO_USER]           NVarChar(256)         NOT NULL,
        CONSTRAINT [PK_dbo.ClientOri] PRIMARY KEY NONCLUSTERED ([CO_ID]),
        CONSTRAINT [FK_dbo.ClientOri(CO_ID_CLIENT)_dbo.ClientTable(ClientID)] FOREIGN KEY  ([CO_ID_CLIENT]) REFERENCES [dbo].[ClientTable] ([ClientID])
);
GO
CREATE UNIQUE CLUSTERED INDEX [UC_dbo.ClientOri(CO_ID_CLIENT,CO_STATUS,CO_ID)] ON [dbo].[ClientOri] ([CO_ID_CLIENT] ASC, [CO_STATUS] ASC, [CO_ID] ASC);
GO
